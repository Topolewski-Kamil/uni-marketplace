Rails.application.routes.draw do
  resources :messages
  resources :conversations
  post 'conversations', to: 'conversations#create'
  post 'messages', to: 'messages#create'

  get 'search_listing', to: 'listings#search_listing'

  get '/listing_review', to: 'listings#review_list'
  post '/listing_review', to: 'listings#review_list'

  mount EpiCas::Engine, at: "/"
  devise_for :users
  
  get '/listings/:id/edit/:image_ids', to: 'listings#delete_image', as: 'delete_image'

  resources :listings do 
    collection do
      get 'validate'
    end
  end

  match "/403", to: "errors#error_403", via: :all
  match "/404", to: "errors#error_404", via: :all
  match "/422", to: "errors#error_422", via: :all
  match "/500", to: "errors#error_500", via: :all

  get :ie_warning, to: 'errors#ie_warning'
  get :javascript_warning, to: 'errors#javascript_warning'

  root to: "listings#index"
  get 'search', to: "listings#search"

  get "/pages/:page" => "pages#show"
  
  get "/moderator", to: "moderator#index"

  resources :categories
  post "/categories/add_category", to: "categories#add_category"
  post "/categories/delete_category", to: "categories#delete_category"

  

  #policy edits
  get "/policies/parse" => "policies#parse"
  get "/policies/:page" => "policies#show"
  get "/policies/edit/:page" => "policies#edit"
  post "/policies/update/:page" => "policies#update"

  get "/users/get_moderators/" => "users#get_moderators"
  get "/users/search/" => "users#search"
  post "/users/grant_moderator/" => "users#grant_moderator"
  post "/users/revoke_moderator/" => "users#revoke_moderator"
  post "/users/ban/" => "users#ban_user"
  post "/users/unban/" => "users#unban_user"
  resources :users
  

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end