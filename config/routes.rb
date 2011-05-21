Tracks::Application.routes.draw do

  resources :invoices
  resources :bills
  resources :groups
  resources :permissions
  resources :work_units
  resources :clients
  resource :user_session
  resources :users
  resources :projects

  # match '/forbid' => 'permissions#destroy', :as => :forbid, :via => delete
  # match '/permit' => 'permissions#create', :as => :permit, :via => post
  # match '/ungroup_user' => 'groups_users#destroy', :as => :ungroup_user, :via => delete
  # match '/group_user' => 'groups_users#create', :as => :group_user, :via => post

  match '/work_units/switch' => 'work_units#switch', :as => :switch_work_unit, :via => :post
  match '/set_current_project/:id' => 'current_project#create', :as => :set_current_project, :via => :post
  match '/login' => 'user_sessions#new', :as => :login
  match '/logout' => 'user_sessions#destroy', :as => :logout
  match '/clock_in_on/:id' => 'clock_time#create', :as => :clock_in, :via => :post
  match '/clock_out/:id' => 'clock_time#destroy', :as => :clock_out, :via => :delete
  match '/' => 'home#index'
  match '/login' => 'user_sessions#new', :as => :default_unauthorized
end
