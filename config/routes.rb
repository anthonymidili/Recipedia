Rails.application.routes.draw do
  root 'sites#index'
  devise_for :users
  get 'sites/index'

  resources :recipes
  resources :categories
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
