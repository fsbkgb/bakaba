Bakaba::Application.routes.draw do

  get "log_out" => "sessions#destroy", :as => "log_out"
  get "log_in" => "sessions#new", :as => "log_in"

  get "users/new"

  get "pages/home"
  get "pages/help"
  get "pages/contact"
  get "pages/rules"
  
  match '/', :to => 'pages#home'
  match '/help',    :to => 'pages#help'
  match '/contact',    :to => 'pages#contact'
  match '/rules',    :to => 'pages#rules'

  resources :categories
  resources :boards
  resources :posts
  resources :comments
  resources :users
  resources :sessions

  scope :as => "board" do
    resources :posts
  end
  
  scope :as => "post" do
    resources :comments
  end 
  
  root :to => 'pages#home'

end
