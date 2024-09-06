Rails.application.routes.draw do
  root 'users#profile'

  devise_for :users,
             controllers: {
               registrations: 'users/registrations',
               sessions: 'users/sessions',
               passwords: 'users/passwords'
             }

  resources :runs, except: %i[index]

  resources :users, only: %i[show] do
    resource :user_settings,
             only: %i[update],
             path: 'settings',
             as: :settings,
             controller: 'user_settings'
  end

  resources :teams do
    resource :team_settings,
             only: %i[update],
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

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up', to: 'rails/health#show', as: :rails_health_check
end
