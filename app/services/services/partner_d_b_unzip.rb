# frozen_string_literal: true

module Services
  class PartnerDBUnzip
    def initialize(task)
      @task_name = task['name']
      parsed_task_data = JSON.parse(task.data)
      @archive_name = parsed_task_data['archive_name']
      @file_name = parsed_task_data['file_name']
    end

    def call
      return false unless start_conditions_satisfied?

      `gzip -df #{@archive_name}`
      finish_conditions_satisfied?
    end

    private

    def start_conditions_satisfied?
      if File.exist?(@archive_name)
        Rails.logger.info "Partner DB file found, unzipping started"
        true
      else
        Rails.logger.info "No partner DB file found"
        false
      end
    end

    def finish_conditions_satisfied?
      if File.exist?(@file_name)
        Rails.logger.info "Partner DB file successfully unzipped to #{@file_name}"
        true
      else
        Rails.logger.info "Partner DB file failed to unzip - no #{@file_name} found"
        false
      end
    end
  end
end
