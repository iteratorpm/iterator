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

  resource :security_settings
  resource :memberships

  resource :projects do
    member do
      get :memberships
      post :archive
    end
  end

  resources :organizations do
    resources :memberships, except: [:show] do
      collection do
        get :report
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

  resource :notification_settings, only: [:edit, :update, :show] do
    post :toggle_mute_project, on: :collection
  end

  root "projects#index"
end
