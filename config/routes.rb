Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get 'updates/parse_single_page'
  get 'updates/create_base_rating_data'
  get 'updates/download_partner_db'
  get 'updates/unzip_partner_db'
  get 'updates/split_partner_db_to_segments'
  get 'updates/parse_partner_db_segments'
end
