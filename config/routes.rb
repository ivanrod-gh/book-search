Rails.application.routes.draw do
  root 'searches#index'
  
  get 'searches/index'
  post 'searches/full_text'
  post 'searches/with_filters'
end
