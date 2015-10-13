TimePulse::Application.routes.draw do


  resources :activities, :only => [:create]
  resources :invoices
  resources :bills
  resources :groups
  resource :user_api_tokens, :only => :update
  resources :permissions
  resources :work_units, :except => :index
  resources :clients
  resources :calendar_work_units, :only => :index
  resources :hours_reports, :only => [:index, :create]
  resources :calendars, :only => :index
  resources :projects do
    resource :github_pull, :controller => 'github_pull', :only => [:create]
    resource :pivotal_pull, :controller => 'pivotal_pull', :only => [:create]
  end
  resources :rates, :only => :update

  resources :project_reports
  resources :invoice_reports, :only => :show

  resource :github, :only => [:create], :controller => 'github'
  resource :pivotal, :only => [:create], :controller => 'pivotal'
  resource :user_preferences, :only => [ :edit, :update ]

  # TODO: Reenable these once LAz is working
  # match '/forbid' => 'permissions#destroy', :as => :forbid, :via => delete
  # match '/permit' => 'permissions#create', :as => :permit, :via => post
  # match '/ungroup_user' => 'groups_users#destroy', :as => :ungroup_user, :via => delete
  # match '/group_user' => 'groups_users#create', :as => :group_user, :via => post

  devise_for :users, :controllers => {:registrations => 'users' }
  devise_scope :user do
    get "/login" => "devise/sessions#new", :as => :login
    get "/logout" => "devise/sessions#destroy", :as => :logout
    get "/users/new" => "users#new", :as => :new_user
    get "/users" => "users#index", :as => :users
    get "/users/:id" => "users#show", :as => :user
    get "/users/:id/edit" => "users#edit", :as => :edit_user
    patch "/users/:id" => "users#update", :as => :update_user
  end
  match '/fix_work_unit/:id' => 'work_unit_fixer#create', :as => :fix_work_unit, :via => :post
  match '/set_current_project/:id' => 'current_project#create', :as => :set_current_project, :via => :post
  match '/clock_in_on/:id' => 'clock_time#create', :as => :clock_in, :via => :post
  match '/clock_out' => 'clock_time#destroy', :as => :clock_out, :via => :delete
  match '/add_annotation' => 'annotations#create', :as => :add_annotation, :via => :post

  root :to => 'home#index'

  get "my_bills" => "my_bills#index", :as => :my_bills
  get "my_bills/:bill_id" => "my_bills#show", :as => :my_bill

end