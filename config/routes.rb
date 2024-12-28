Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

    # User routes (optional, can be used for user registration if needed)
    resources :users
    get '/current_user', to: 'users#get_current_user'  # Route for current_user action
    
  # Get the current dynasty
    post '/dynasties/set_current', to: 'dynasties#set_current_dynasty'
    get '/dynasties/current', to: 'dynasties#get_current_dynasty'
    get '/dynasties/current/players', to: 'dynasties#current_dynasty_players'
    put '/dynasties/current/advance_class_years', to: 'dynasties#advance_class_years'

    resources :dynasties do
      member do
        get :current_dynasty_players
      end
      collection do
        get :get_current_dynasty
      end
    end


    resources :players
  
    # Session routes for login/logout
    resource :session, only: [:create, :destroy]
  
end
