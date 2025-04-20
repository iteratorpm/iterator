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

    post 'avatar', to: 'profiles#update_avatar'
    delete 'avatar', to: 'profiles#remove_avatar'

    delete 'revoke_app/:id', to: 'profiles#revoke_app', as: :revoke_app
  end

  get "analytics", to: "profile#recent_analytics"

  resources :security_settings
  resources :memberships

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
      get 'profile', to: 'projects#profile'
      patch 'profile', to: 'projects#update_profile'
      post 'profile/preview', to: 'projects#preview'
      get :import
      get :export
    end

    resources :recover_stories, only: [:index, :create], module: 'projects'

    resources :analytics do
      get :overview
      get :charts, on: :member
    end

    resources :templates, only: [:index]
    resources :review_types, only: [:index]

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
      get "projects/report", to: "organizations#project_report", as: :projects_report
    end
    post :set_default
  end

  resources :notifications, only: [:index] do
    post :mark_as_read, on: :member
    post :mark_all_as_read, on: :collection
  end

  resources :notification_settings, only: [:edit, :update, :show] do
    post :toggle_mute_project, on: :collection
  end

  root "projects#index"
end
