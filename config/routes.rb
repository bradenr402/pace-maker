Rails.application.routes.draw do
  # Home
  get 'home/index'

  authenticated :user do
    root 'home#index', as: :authenticated_root
  end

  unauthenticated do
    root 'pages#landing'
  end
  get :landing, to: 'pages#landing'

  # Devise
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  devise_scope :user do
    post 'users/sign_out_all',
         to: 'users/sessions#sign_out_all_devices',
         as: :sign_out_all_devices
  end

  # Runs
  resources :runs, except: %i[index] do
    member do
      post :enable_comments
      post :disable_comments
    end

    # Liking runs
    resources :likes, only: %i[create destroy], module: :runs

    # Commenting on runs
    resources :comments, only: %i[create], module: :runs do
      get :load_more, on: :collection
    end
  end
  get 'runs/:id/details', to: 'runs#details', as: 'run_details'

  # Comments
  resources :comments, only: %i[show edit update destroy] do
    member do
      get :cancel_edit
      get :reply
      get :cancel_reply
    end

    # Liking comments
    resources :likes, only: %i[create destroy], module: :comments

    # Commenting on comments
    resources :comments, only: %i[create], module: :comments
  end

  # Users & Settings
  resources :users, only: %i[show] do
    resource :user_settings,
             only: %i[update],
             path: 'settings',
             as: :settings,
             controller: 'user_settings' do
      post :reset
    end
    delete 'unlink_google_account', on: :member
    delete 'unlink_strava_account', on: :member
  end
  get '/profile', to: 'users#profile'

  # Teams & Memberships
  resources :teams do
    resource :team_settings,
             only: %i[update show],
             path: 'settings',
             as: :settings,
             controller: 'team_settings' do
      post :reset
    end

    member do
      post :remove_member
      post :join
      post :leave
    end

    get 'member/:user_id', to: 'teams#member', as: 'member'
    resources :team_memberships, param: :user_id, only: %i[edit update]

    # Topics & Messages
    get 'main_chat', to: 'teams#main_chat', as: :main_chat
    resources :topics, except: %i[new] do
      member do
        patch :close
        patch :reopen
        patch :favorite
        patch :unfavorite
        post :update_last_read
      end

      resources :messages, only: %i[index show create edit update destroy] do
        resources :likes, only: %i[create destroy], module: :messages

        member do
          patch :pin
          patch :unpin
          get :cancel_edit
        end

        get :load_more, on: :collection
      end

      post 'typing', to: 'typing#update'
    end
  end

  # Team Join Requests
  resources :team_join_requests, only: %i[update] do
    member do
      patch :cancel
      patch :approve
      patch :reject
    end
  end

  # Search
  get 'search', to: 'search#index', as: :search

  # Pinned Pages
  resources :pinned_pages, only: %i[create destroy] do
    collection do
      get :manage
      patch :update_all
    end
  end

  # Feedback
  resources :feedback_form, only: %i[create]

  # Strava
  resource :strava_imports, only: %i[create destroy]
  post 'webhooks/strava', to: 'strava_webhooks#receive'
  get 'webhooks/strava', to: 'strava_webhooks#verify'

  # Policies & Legal
  get 'privacy_policy', to: 'pages#privacy_policy'
  get 'strava_policy', to: 'pages#strava_policy'
  get 'google_policy', to: 'pages#google_policy'

  # PWA Support
  get 'service-worker.js', to: 'service_worker#service_worker', as: :pwa_service_worker
  get 'manifest.json', to: 'service_worker#manifest', as: :pwa_manifest

  # Health Check
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up', to: 'rails/health#show', as: :rails_health_check
end
