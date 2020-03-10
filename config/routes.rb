Rails.application.routes.draw do
  root 'recipes#index'

  devise_for :users

  resources :recipes do
    resources :reviews
    collection do
      get :search
    end
    member do
      get :log_in
    end
  end

  resources :categories

  resources :users, only: [:show]

  resources :favoritisms, only: [:create, :destroy]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
