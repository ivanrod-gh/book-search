# frozen_string_literal: true

module Services
  module WorkerTasks
    class RequestDBFill
      FILL_APP_D_B_TASKS = %w[
        partner_db_download_simple
        partner_db_download_detailed
        partner_db_unzip_simple
        partner_db_unzip_detailed
        partner_db_parse_segments_simple
        partner_db_parse_segments_detailed
      ].freeze

      def call
        create_tasks_for_partner_db('simple')
        create_tasks_for_partner_db('detailed')
        check_tasks
      end

      private

      def create_tasks_for_partner_db(type)
        Services::WorkerTasks::Create.new.partner_db_download(type)
        Services::WorkerTasks::Create.new.partner_db_unzip(type)
        Services::WorkerTasks::Create.new.partner_db_parse_segments(type)
      end

      def check_tasks
        FILL_APP_D_B_TASKS.each do |task_name|
          return false if WorkerTask.where(name: task_name).count.zero?
        end
        true
      end
    end
  end
end
