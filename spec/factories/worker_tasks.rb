FactoryBot.define do
  factory :worker_task do
    name { 'test_task_name' }
    data { 'test_task_data' }

    trait :download_simple do
      name { 'partner_db_download_simple' }
      task_data = {}
      task_data['address'] = 'https://www.litres.ru/static/ds/partners_utf.yml.gz'
      task_data['file_name'] = 'shared/partner_db/partners_utf.yml.gz'
      data { task_data.to_json }
    end

    trait :download_detailed do
      name { 'partner_db_download_detailed' }
      task_data = {}
      task_data['address'] = 'https://www.litres.ru/static/ds/detailed_data.xml.gz'
      task_data['file_name'] = 'shared/partner_db/detailed_data.xml.gz'
      data { task_data.to_json }
    end
    
    trait :unzip_simple do
      name { 'partner_db_unzip_simple' }
      task_data = {}
      task_data['archive_name'] = 'shared/partner_db/partners_utf.yml.gz'
      task_data['file_name'] = 'shared/partner_db/partners_utf.yml'
      data { task_data.to_json }
    end
    
    trait :unzip_detailed do
      name { 'partner_db_unzip_detailed' }
      task_data = {}
      task_data['archive_name'] = 'shared/partner_db/detailed_data.xml.gz'
      task_data['file_name'] = 'shared/partner_db/detailed_data.xml'
      data { task_data.to_json }
    end
    
    trait :parse_segments_simple do
      name { 'partner_db_parse_segments_simple' }
      task_data = {}
      task_data['file_name'] = 'shared/partner_db/partners_utf.yml'
      task_data['end_of_line'] = '</offer>'
      task_data['book_key'] = 'offer'
      data { task_data.to_json }
    end
    
    trait :parse_segments_detailed do
      name { 'partner_db_parse_segments_detailed' }
      task_data = {}
      task_data['file_name'] = 'shared/partner_db/detailed_data.xml'
      task_data['end_of_line'] = '</art>'
      task_data['book_key'] = 'art'
      data { task_data.to_json }
    end

    trait :remote_parse do
      name { 'remote_page_parse' }
      task_data = {}
      task_data['int_id'] = '121281'
      data { task_data.to_json }
    end
  end
end
