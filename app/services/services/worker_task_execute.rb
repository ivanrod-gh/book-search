# frozen_string_literal: true

module Services
  class WorkerTaskExecute
    TASKS_SERVICES = {
      'partner_db_download_simple' => 'PartnerDBDownload',
      'partner_db_download_detailed' => 'PartnerDBDownload',
      'partner_db_unzip_simple' => 'PartnerDBUnzip',
      'partner_db_unzip_detailed' => 'PartnerDBUnzip',
      'partner_db_parse_segments_simple' => 'PartnerDBParse',
      'partner_db_parse_segments_detailed' => 'PartnerDBParse'
    }.freeze

    attr_reader :task

    def initialize
      @task = WorkerTask.first
    end

    def call
      return false unless start_conditions_satisfied?

      Rails.logger.info "Worker started [#{task.name}] task"
      respond = Services.const_get(TASKS_SERVICES[task.name]).new(task).call
      if respond
        task.destroy
        Rails.logger.info "Task successfully completed, removing task from worker_tasks table"
      else
        Rails.logger.info "Task execution failed"
      end
    end

    private

    def start_conditions_satisfied?
      if task
        Rails.logger.info "Found task [#{task.name}], executing"
        true
      else
        Rails.logger.info "Worker manager reporting: OK - all tasks completed"
        false
      end
    end
  end
end
