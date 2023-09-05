# frozen_string_literal: true

module Services
  class WorkerTaskCreate
    def partner_db_download(type)
      case type
      when 'simple'
        partner_db_download_simple
      when 'detailed'
        partner_db_download_detailed
      end
    end

    def partner_db_unzip(type)
      case type
      when 'simple'
        partner_db_unzip_simple
      when 'detailed'
        partner_db_unzip_detailed
      end
    end

    def partner_db_parse_segments(type)
      case type
      when 'simple'
        partner_db_parse_segments_simple
      when 'detailed'
        partner_db_parse_segments_detailed
      end
    end

    private

    def partner_db_download_simple(data = {})
      data['address'] = 'https://www.litres.ru/static/ds/partners_utf.yml.gz'
      data['file_name'] = 'shared/partner_db/partners_utf.yml.gz'
      WorkerTask.create(name: __method__.to_s, data: data.to_json)
    end

    def partner_db_download_detailed(data = {})
      data['address'] = 'https://www.litres.ru/static/ds/detailed_data.xml.gz'
      data['file_name'] = 'shared/partner_db/detailed_data.xml.gz'
      WorkerTask.create(name: __method__.to_s, data: data.to_json)
    end

    def partner_db_unzip_simple(data = {})
      data['archive_name'] = 'shared/partner_db/partners_utf.yml.gz'
      data['file_name'] = 'shared/partner_db/partners_utf.yml'
      WorkerTask.create(name: __method__.to_s, data: data.to_json)
    end

    def partner_db_unzip_detailed(data = {})
      data['archive_name'] = 'shared/partner_db/detailed_data.xml.gz'
      data['file_name'] = 'shared/partner_db/detailed_data.xml'
      WorkerTask.create(name: __method__.to_s, data: data.to_json)
    end

    def partner_db_parse_segments_simple(data = {})
      data['file_name'] = 'shared/partner_db/partners_utf.yml'
      data['end_of_line'] = '</offer>'
      data['book_key'] = 'offer'
      WorkerTask.create(name: __method__.to_s, data: data.to_json)
    end

    def partner_db_parse_segments_detailed(data = {})
      data['file_name'] = 'shared/partner_db/detailed_data.xml'
      data['end_of_line'] = '</art>'
      data['book_key'] = 'art'
      WorkerTask.create(name: __method__.to_s, data: data.to_json)
    end
  end
end
