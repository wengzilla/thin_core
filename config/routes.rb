ThinCore::Application.routes.draw do
  
  namespace :api do
    namespace :v1 do
      resources :messages, :only => [:index, :create]
      resources :users, :only => [:index]
      resources :agents, :onlly => [:index]
      resources :rooms, :only => [:index]
      resources :alerts, :only => [:create]
    end
  end

  resources :messages
  resources :rooms do
    member do
      post 'send_log'
    end
  end
  
  resources :guests, :only => [:update]
  resources :agents, :only => [:index]
  
  mount Resque::Server, :at => "/resque"

  root :to => 'rooms#index'
end
