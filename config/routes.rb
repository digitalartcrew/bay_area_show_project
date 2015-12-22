Rails.application.routes.draw do
    
  root to: 'shows#index'
   
  get '/login', to: "sessions#login", as: 'login'

  post '/login', to: "sessions#attempt_login"

  get '/signup', to: "sessions#signup", as: 'signup'

  post '/signup', to: "sessions#create"
  
  delete '/logout', to: "sessions#logout", as: "logout"

  post '/attending', to: "shows#attending", as: "attending"

  get '/refresh', to: "shows#refresh", as: "refresh"

    
    resources :sessions, only: [:create, :destroy]

    
    resources :users do    
    resources :shows, shallow: true
    member do
      get :follow
      get :unfollow
    end
  end
  end