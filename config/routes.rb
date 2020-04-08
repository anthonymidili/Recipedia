Rails.application.routes.draw do
  get 'notifications/index'
  root 'recipes#index'

  devise_for :users

  resources :recipes do
    resources :reviews, only: [:create, :edit, :update, :destroy]
    collection do
      get :search
    end
    member do
      get :log_in
      get :likes
    end
  end

  resources :categories

  resources :users, only: [:show, :edit, :update] do
    member do
      get :log_in
      get :followers
      get :following
    end
  end

  resources :favoritisms, only: [:create, :destroy]

  resources :relationships, only: [:create, :destroy]

  resources :notifications, only: [:index] do
    collection do
      patch :mark_as_read
      get :unread_count
      get :settings
      patch :update_settings
    end
  end

  get 'sitemap.xml', to: 'sites#sitemap', format: :xml
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
