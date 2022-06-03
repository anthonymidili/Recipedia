Rails.application.routes.draw do
  # Serve websocket cable requests in-process for Passenger Standalone.
  mount ActionCable.server => '/cable'

  root 'recipes#index'

  devise_for :users

  resources :recipes do
    resources :reviews, only: [:show, :create, :edit, :update, :destroy]
    resources :recipe_images, only: [:new, :create, :destroy]
    collection do
      get :search
    end
    member do
      get :log_in
      get :likes
    end
  end

  resources :categories do
    collection do
      get :more
    end
  end

  resources :users, only: [:index, :show, :edit, :update, :destroy] do
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
      get :settings
      patch :update_settings
    end
  end

  get 'sitemap.xml', to: 'sites#sitemap', format: :xml
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
