MapVotes::Application.routes.draw do
  resources :api_keys

  resources :maps do
    post 'vote', on: :member
    resources :map_comments 
  end
  
  namespace :v1, defaults: {format: 'json'} do
    resources :api do
      post 'cast_vote', on: :collection
      post 'write_message', on: :collection
      post 'server_query', on: :collection
    end
    
  end
  root to: "home#index"

  get "/auth/steam/callback" => "sessions#create"
  get "/signout" => "sessions#destroy", as: :signout
end
