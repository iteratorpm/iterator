Rails.application.routes.draw do
  devise_for :users

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  resource :profile, only: [:show, :update], controller: 'profiles' do
    post 'tokens', to: 'profiles#create_token', as: :tokens
    delete 'tokens/:id', to: 'profiles#destroy_token', as: :token

    post :set_default

    post 'avatar', to: 'profiles#update_avatar'
    delete 'avatar', to: 'profiles#remove_avatar'

    delete 'revoke_app/:id', to: 'profiles#revoke_app', as: :revoke_app
  end

  get "analytics", to: "profile#recent_analytics"

  resources :security_settings
  resources :memberships

  resources :favorites, only: [:create, :destroy]

  get '/docs/whats_new_updates', to: 'docs#whats_new_updates', as: :whats_new_updates
  get '/docs(/:page)', to: 'docs#show', as: :docs

  resources :projects do
    resources :webhooks, only: [:index, :create, :destroy], module: 'projects' do
      patch :toggle, on: :member
    end
    resources :memberships, path: "memberships", controller: "project_memberships", only: [:new, :index, :create, :update, :destroy] do
      collection do
        get :search_users
      end
    end
    member do
      post :archive
    end

    resources :iterations, module: "projects", only: [:update] do
      collection do
        get :done
        get :current
        get :current_backlog
        get :backlog
      end
    end

    resources :stories, module: "projects", except: [:index] do
      member do
        patch :reject
        get :rejection
      end

      collection do
        get :icebox
        get :my_work
        get :blocked
      end
    end

    resources :comments, module: "projects", only: [:create, :destroy] do
      collection do
        post :preview
      end
    end

    resources :epics, module: "projects", only: [:new, :create, :index, :destroy, :update]
    resources :labels, module: "projects", only: [:new, :create, :index, :edit, :update, :destroy] do
      member do
        patch :convert_to_epic
      end
    end
    resources :histories, module: "projects", only: [:index]

    get 'search', to: 'projects/search#index', as: :search

    resources :csv_exports, path: "export", module: "projects", only: [:index, :create] do
      member do
        get :download
      end
    end

    resources :csv_imports, path: "import", module: "projects", only: [:index, :create]

    member do
      get 'profile', to: 'projects/profile#show'
      patch 'profile', to: 'projects/profile#update'
      post 'profile/preview', to: 'projects/profile#preview'
    end
    resources :recover_stories, only: [:index, :create], module: 'projects'

    namespace :analytics do
      get 'overview', to: 'overview#index', as: :overview
      resources :epics, only: [:index, :show] do
        get :csv, on: :collection
      end
      resources :releases, only: [:index, :show] do
        get :csv, on: :collection
      end
      resources :stories, only: [:index]
      resources :projections, only: [:index]
      resources :iterations, only: [:show]
      resources :cycle_times, only: [:index] do
        collection do
          get :export
        end
      end
    end

    namespace :charts do
      get 'velocity', to: 'projects/charts#update'
      get 'composition', to: 'projects/charts#composition'
    end

    resources :description_templates, path:'templates', module: 'projects', except: [:show] do
      collection do
        post :preview
      end
    end
    resources :review_types, module: 'projects', except: [:show, :edit] do
      member do
        patch :toggle_hidden
      end
    end

    resources :memberships, only: [:index]
    resources :integrations, path: 'integrations', controller: 'project_integrations', except: [:show]

  end

  resources :organizations do
    resources :github_integrations, only: [:edit]
    resources :integrations, controller: 'integrations', except: [:show]

    resources :memberships, except: [:show] do
      collection do
        get :report
        post :create_with_new_user
      end
    end

    member do
      get :plans_and_billing
      get :projects
      get :project_report
    end
  end

  resources :notifications, only: [:index] do
    post :mark_as_read, on: :member
    post :mark_all_as_read, on: :collection
  end

  patch '/notification_settings', to: 'notification_settings#update', as: :notification_settings
  get '/notification_settings', to: 'notification_settings#index'

  root "projects#index"
end
