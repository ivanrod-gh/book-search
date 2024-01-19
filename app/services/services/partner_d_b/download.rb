# frozen_string_literal: true

module Services
  module PartnerDB
    class Download
      def initialize(task)
        @task_name = task['name']
        parsed_task_data = JSON.parse(task.data)
        @address = parsed_task_data['address']
        @file_name = parsed_task_data['file_name']
      end

      def call
        manage_file_directory
        download_file
        finish_conditions_satisfied?
      end

      private

      def manage_file_directory
        dir_path = @file_name.split('/')
        dir_path.pop
        dir_path = dir_path.join('/')
        FileUtils.mkdir_p(dir_path) unless Dir.exist?(dir_path)
      end

      def download_file
        `wget -O #{@file_name} #{@address}`
      end

      def finish_conditions_satisfied?
        if File.exist?(@file_name)
          Rails.logger.info "Partner DB file successfully downloaded to #{@file_name}"
          true
        else
          Rails.logger.info "Partner DB file failed to download - no #{@file_name} found"
          false
        end
      end
    end
  end
end
