Rails.application.routes.draw do
  root 'recipes#index'

  devise_for :users

  resources :recipes do
    resources :reviews, only: [:create, :edit, :update, :destroy]
    collection do
      get :search
    end
    member do
      get :log_in
    end
  end

  resources :categories

  resources :users, only: [:show, :edit, :update]

  resources :favoritisms, only: [:create, :destroy]

  get 'sitemap.xml', to: 'sites#sitemap', format: :xml
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
