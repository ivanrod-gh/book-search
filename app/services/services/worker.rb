# frozen_string_literal: true

module Services
  class Worker
    COOLDOWN_TABLE_BY_REASON_AND_TRY = {
      'empty_page' => [5],
      '403' => [15, 30, 60, 300]
    }.freeze

    # Минимальный откат воркера, пресекает спам со стороны воркера в сторону удаленного приложения
    # В подсчете времени отката используется метод округления .round(0), поэтому 1 секунда отката реально >= 0.5 секунды
    # Округление разрешает ситуацию с запуском через тот же крон с установкой "раз в 1 секунду", когда воркер реально
    # запустится через 0.9(9) секунды вместо 1 секунды и нарвется на минимальный откат
    MINIMUM_COOLDOWN = 1

    class << self
      attr_accessor :task_execution_status
    end

    attr_accessor :worker_status

    def initialize
      (@worker_status = WorkerStatus.first).nil? ? @worker_status = WorkerStatus.create! : worker_status
    end

    def call
      return unless worker_ready_to_work?

      check_tasks
    rescue Exception => e
      manage_exception(e)
    end

    private

    def worker_ready_to_work?
      check_pid if worker_status.pid
      return false unless worker_ready?

      return false unless cooldown_finished?

      assign_pid_and_started_at
    end

    def check_pid
      reset_worker_status if `ps -p #{worker_status.pid} -o comm=` != "ruby\n"
    end

    def worker_ready?
      if worker_status.pid.nil?
        logger_and_respond('Worker: not busy (no old pid execution found)')
      else
        logger_and_respond("Worker: busy (pid=#{worker_status.pid})", false)
      end
    end

    def logger_and_respond(message, state = true)
      Rails.logger.info message
      state
    end

    def reset_worker_status(type = 'initial')
      worker_status.update!(
        pid: nil,
        started_at: (type == 'initial' ? nil : WorkerStatus.first.started_at),
        cooldown_until: nil,
        cooldown_reason: nil,
        try: 0
      )
    end

    def cooldown_finished?
      cooldown = maximum_cooldown
      if cooldown.positive?
        logger_and_respond("Worker: under cooldown (#{cooldown}s remaining)", false)
      else
        logger_and_respond('Worker: no cooldown found')
      end
    end

    def maximum_cooldown(minimum_cooldown = 0, current_cooldown = 0)
      if worker_status.started_at
        minimum_cooldown = (worker_status.started_at + MINIMUM_COOLDOWN - Time.zone.now).round(0)
      end
      current_cooldown = (worker_status.cooldown_until - Time.zone.now).round(0) if worker_status.cooldown_until
      minimum_cooldown > current_cooldown ? minimum_cooldown : current_cooldown
    end

    def assign_pid_and_started_at
      Rails.logger.info "Worker: start working"
      worker_status.update(pid: Process.pid, started_at: Time.zone.now)
    end

    def check_tasks
      if worker_have_tasks?
        check_callback_state(Services::WorkerTaskExecute.new.call)
      elsif app_d_b_empty?
        app_d_b_fill
      # Т.к. книжные сайты агрессивно препятствуют парсингу, то 'живой' сбор данных не используется
      # elsif remote_parse_goals_empty?
      #   remote_parse_goals_fill
      # elsif its_time_for_generate_remote_parsing_tasks?
      #   generate_remote_parsing_tasks
      # Оценки, комментарии и прочие данные, добываемые удаленным парсингом, заменены на сгенерированные
      elsif ratings_empty?
        generate_additional_book_data
      else
        finish_worker_instance_iteration
      end
    end

    def worker_have_tasks?
      WorkerTask.count.positive?
    end

    def check_callback_state(respond)
      if respond
        reset_worker_status('final')
        Rails.logger.info 'Worker: successful execution, reset worker status'
      else
        manage_task_execution_error
      end
    end

    def manage_task_execution_error
      if Services::Worker.task_execution_status
        reset_worker_status_with_cooldown(Services::Worker.task_execution_status)
      else
        reset_worker_status('final')
        Rails.logger.info 'Worker: finished with error, reset worker status'
      end
    end

    def reset_worker_status_with_cooldown(reason)
      try = calculate_current_try(reason)
      worker_status.update!(
        pid: nil,
        cooldown_until: Time.zone.now + calculate_cooldown(reason, try).seconds,
        cooldown_reason: reason,
        try: try + 1
      )
      Rails.logger.info "Worker: finished with request (#{reason}) for cooldown"
    end

    def calculate_current_try(reason)
      worker_status.cooldown_reason == reason ? worker_status.try : 0
    end

    def calculate_cooldown(reason, try)
      return 0 unless Services::Worker::COOLDOWN_TABLE_BY_REASON_AND_TRY.key?(reason)

      if try >= Services::Worker::COOLDOWN_TABLE_BY_REASON_AND_TRY[reason].size
        return Services::Worker::COOLDOWN_TABLE_BY_REASON_AND_TRY[reason].last
      end

      Services::Worker::COOLDOWN_TABLE_BY_REASON_AND_TRY[reason][try]
    end

    def app_d_b_empty?
      Book.count.zero?
    end

    def app_d_b_fill
      check_callback_state(Services::WorkerTaskRequestDBFill.new.call)
    end

    def remote_parse_goals_empty?
      RemoteParseGoal.count.zero?
    end

    def remote_parse_goals_fill
      check_callback_state(Services::WorkerTaskRequestRemoteParseGoalsFill.new.call)
    end

    def its_time_for_generate_remote_parsing_tasks?
      RemoteParseGoal.where("? > date", Time.zone.now).count.positive?
    end

    def generate_remote_parsing_tasks
      check_callback_state(Services::WorkerTaskRequestRemoteParseTasksGenerate.new.call)
    end

    def ratings_empty?
      BookRating.count.zero?
    end

    def generate_additional_book_data
      check_callback_state(Services::GenerateAdditionalBookData.new.call)
    end

    def finish_worker_instance_iteration
      reset_worker_status('final')
      Rails.logger.info 'Worker instance reporting: OK - all tasks completed, reset worker status'
      stop_worker_job
    end

    def stop_worker_job
      Rails.logger.info 'Worker: stopping worker job'
      'stop_worker_job'
    end

    def manage_exception(e)
      Rails.logger.info "Worker: an EXCEPTION (#{e}) raised"
      Services::Worker.task_execution_status = '403' if e.message.include?('403')
      if Services::Worker.task_execution_status
        reset_worker_status_with_cooldown(Services::Worker.task_execution_status)
      else
        reset_worker_status('final')
        Rails.logger.info "Worker: reset worker status"
      end
    end
  end
end
