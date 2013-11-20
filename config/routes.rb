TimePulse::Application.routes.draw do

  resources :invoices
  resources :bills
  resources :groups
  resources :permissions
  resources :work_units, :except => :index
  resources :clients
  resources :projects do
    resource :github_pull, :controller => 'github_pull', :only => [:create]
    resource :pivotal_pull, :controller => 'pivotal_pull', :only => [:create]
  end
  resources :rates, :only => :update

  resources :invoice_reports, :only => :show

  resource :github, :only => [:create], :controller => 'github'
  resource :pivotal, :only => [:create], :controller => 'pivotal'

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
    get "/users/:id/edit" => "users#edit", :as => :edit_user
    put "/users/:id" => "users#update", :as => :user
  end
  match '/fix_work_unit/:id' => 'work_unit_fixer#create', :as => :fix_work_unit
  match '/set_current_project/:id' => 'current_project#create', :as => :set_current_project, :via => :post
  match '/clock_in_on/:id' => 'clock_time#create', :as => :clock_in, :via => :post
  match '/clock_out' => 'clock_time#destroy', :as => :clock_out, :via => :delete

  root :to => 'home#index'

end
