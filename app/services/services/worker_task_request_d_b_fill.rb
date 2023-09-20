# frozen_string_literal: true

module Services
  class WorkerTaskRequestDBFill
    FILL_APP_D_B_TASKS = %w[
      partner_db_download_simple
      partner_db_download_detailed
      partner_db_unzip_simple
      partner_db_unzip_detailed
      partner_db_parse_segments_simple
      partner_db_parse_segments_detailed
    ].freeze

    def call
      Services::WorkerTaskCreate.new.partner_db_download('simple')
      Services::WorkerTaskCreate.new.partner_db_unzip('simple')
      Services::WorkerTaskCreate.new.partner_db_parse_segments('simple')
      Services::WorkerTaskCreate.new.partner_db_download('detailed')
      Services::WorkerTaskCreate.new.partner_db_unzip('detailed')
      Services::WorkerTaskCreate.new.partner_db_parse_segments('detailed')
      check_tasks
    end

    private

    def check_tasks
      FILL_APP_D_B_TASKS.each do |task_name|
        return false if WorkerTask.where(name: task_name).count.zero?
      end
      true
    end
  end
end
