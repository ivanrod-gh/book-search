# frozen_string_literal: true

module Services
  module WorkerTasks
    class Execute
      TASKS_SERVICES = {
        'partner_db_download_simple' => 'PartnerDB::Download',
        'partner_db_download_detailed' => 'PartnerDB::Download',
        'partner_db_unzip_simple' => 'PartnerDB::Unzip',
        'partner_db_unzip_detailed' => 'PartnerDB::Unzip',
        'partner_db_parse_segments_simple' => 'PartnerDB::Parse::Execute',
        'partner_db_parse_segments_detailed' => 'PartnerDB::Parse::Execute',
        'remote_page_parse' => 'RemotePageParse'
      }.freeze

      attr_reader :task

      def initialize
        @task = WorkerTask.first
      end

      def call
        return false unless start_conditions_satisfied?

        check_state(Services.const_get(TASKS_SERVICES[task.name]).new(task).call)
      end

      private

      def start_conditions_satisfied?
        if task
          logger_and_respond("Found task [#{task.name}], executing")
        else
          logger_and_respond('Worker task execution failed - no task found', false)
        end
      end

      def check_state(respond)
        if respond
          task.destroy
          logger_and_respond('Worker task successfully completed, removing task from worker_tasks table')
        else
          logger_and_respond('Worker task execution failed', false)
        end
      end

      def logger_and_respond(message, state = true)
        Rails.logger.info message
        state
      end
    end
  end
end
