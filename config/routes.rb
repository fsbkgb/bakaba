Bakaba::Application.routes.draw do

  get "log_out" => "sessions#destroy", :as => "log_out"
  get "log_in" => "sessions#new", :as => "log_in"

  get "users/new"

  get "pages/home"
  get "pages/help"
  get "pages/contact"
  get "pages/rules"
  
  match '/', :to => 'pages#home'
  match '/help', :to => 'pages#help'
  match '/contact', :to => 'pages#contact'
  match '/rules', :to => 'pages#rules'
  match ':board_id' => "boards#show", constraints: {board_id: /\w{1,3}/}
  match '/new/board' => "boards#new"
  match '/boards/:board_id' => "boards#update", constraints: {board_id: /\w{1,3}/}
  match ':post_id' => "posts#show", constraints: {post_id: /\w{1,3}-\d+/}
  match 'del/:post_id' => "posts#destroy", constraints: {post_id: /\w{1,3}-\d+/}
  match 'del/:post_id/post/:comment_id' => "comments#destroy", constraints: {post_id: /\w{1,3}-\d+/, comment_id: /\d+/}
  match "/boards/:id" => redirect("/%{id}")
  match "/posts/:id" => redirect("/%{id}")

  resources :categories
  resources :boards
  resources :posts, :only => [:create, :show] do
    resources :comments, :only => [:create]
  end
  resources :users
  resources :sessions

  scope :as => "board" do
    resources :posts
  end
  
  root :to => 'pages#home'

end
