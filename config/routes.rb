Tracks::Application.routes.draw do

  resources :invoices
  resources :bills
  resources :groups
  resources :permissions
  resources :work_units, :except => :index
  resources :clients
  resources :projects

  resource :github, :only => [:create], :controller => 'github'

  # TODO: Reenable these once LAz is working
  # match '/forbid' => 'permissions#destroy', :as => :forbid, :via => delete
  # match '/permit' => 'permissions#create', :as => :permit, :via => post
  # match '/ungroup_user' => 'groups_users#destroy', :as => :ungroup_user, :via => delete
  # match '/group_user' => 'groups_users#create', :as => :group_user, :via => post

  devise_for :users, :controllers => {:registrations => 'users' }
  devise_scope :user do
    get "/login" => "devise/sessions#new", :as => :login
    match "/logout" => "devise/sessions#destroy", :as => :logout
    get "/users/new" => "users#new", :as => :new_user
    get "/users" => "users#index", :as => :users
    get "/users/:id" => "users#show", :as => :user
    get "/users/:id/edit_as_admin" => "users#edit_as_admin", :as => :edit_user
    put "/users/:id" => "users#update_as_admin", :as => :user
  end
  match '/work_units/switch' => 'work_units#switch', :as => :switch_work_unit, :via => :post
  match '/fix_work_unit/:id' => 'work_unit_fixer#create', :as => :fix_work_unit
  match '/set_current_project/:id' => 'current_project#create', :as => :set_current_project, :via => :post
  match '/clock_in_on/:id' => 'clock_time#create', :as => :clock_in, :via => :post
  match '/clock_out' => 'clock_time#destroy', :as => :clock_out, :via => :delete


  root :to => 'home#index'

end
