Rails.application.routes.draw do
  root 'users#profile'

  devise_for :users,
             controllers: {
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

  resources :runs, except: %i[index]

  resources :users, only: %i[show] do
    resource :user_settings,
             only: %i[update],
             path: 'settings',
             as: :settings,
             controller: 'user_settings'
    delete 'unlink_google_account', on: :member
  end

  resources :teams do
    resource :team_settings,
             only: %i[update show],
             path: 'settings',
             as: :settings,
             controller: 'team_settings'

    member do
      post :remove_member
      post :join
      post :leave
    end

    get 'member/:user_id', to: 'teams#member', as: 'member'
    resources :team_memberships, param: :user_id, only: %i[edit update]
  end

  resources :team_join_requests, only: %i[update] do
    member do
      patch :cancel
      patch :approve
      patch :reject
    end
  end

  get 'search', to: 'search#index', as: :search

  resources :pinned_pages, only: %i[create destroy] do
    collection do
      get :manage
      patch :update_all
      patch :reorder
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up', to: 'rails/health#show', as: :rails_health_check
end
