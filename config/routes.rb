Rails.application.routes.draw do
  use_doorkeeper
  devise_for :users, controllers: { omniauth_callbacks: 'oauth_callbacks' }

  root 'searches#show_variants'
  
  get 'searches/show_variants'
  post 'searches/full_text'
  post 'searches/with_filters'
  post 'searches/retrieve_old_search_parameters'

  # В маршрутах пользователя был убран id, т.к. Devise в любом случае запрашивает текущего пользователя
  # Работа с экземпляром текущего пользователя осуществляется через хелпер Devise current_user
  resources :users, only: %i[] do
    collection do
      get :profile
      get :books_shelf
      post :books_show
      get :manage_api
      post :access_token
    end
  end
  post 'user_books/create'
  delete 'user_books/destroy'
  delete 'user_books/destroy_all'
  get 'user_books/send_to_mail'

  namespace :api do
    namespace :v1 do
      resources :profiles, only: [] do
        get :me, on: :collection
      end
      resources :searches, only: [] do
        get :full_text, on: :collection
        get :with_filters, on: :collection
      end
    end
  end

  get '*unmatched_route', to: 'application#not_found'
end
