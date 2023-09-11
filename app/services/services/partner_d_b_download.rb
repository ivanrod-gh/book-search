# frozen_string_literal: true

module Services
  class PartnerDBDownload
    def initialize(task)
      @task_name = task['name']
      parsed_task_data = JSON.parse(task.data)
      @address = parsed_task_data['address']
      @file_name = parsed_task_data['file_name']
    end

    def call
      download_file
      finish_conditions_satisfied?
    end

    private

    def download_file
      # `wget -O #{@file_name} #{@address}` # _TEST_LIMIT_ !!!
      if @task_name == 'partner_db_download_simple'
        `cp /media/sf_Shared/partners_utf.yml.gz shared/partner_db/partners_utf.yml.gz`
      elsif @task_name == 'partner_db_download_detailed'
        `cp /media/sf_Shared/detailed_data.xml.gz shared/partner_db/detailed_data.xml.gz`
      end
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
