Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'oauth_callbacks' }

  root 'searches#index'
  
  get 'searches/index'
  post 'searches/full_text'
  post 'searches/with_filters'
  post 'searches/retrieve_old_search'

  # В маршрутах пользователя был убран id, т.к. Devise в любом случае запрашивает текущего пользователя
  # Работа с экземпляром текущего пользователя осуществляется через хелпер Devise current_user
  resources :users, only: %i[] do
    collection do
      get :profile
      get :books_shelf
      post :books_show
    end
  end
  post 'user_books/create'
  delete 'user_books/destroy'
  delete 'user_books/destroy_all'
  get 'user_books/send_to_mail'

  get '*unmatched_route', to: 'application#not_found'
end
