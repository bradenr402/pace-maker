Rails.application.routes.draw do
  devise_for :users,
             controllers: {
               registrations: 'users/registrations',
               sessions: 'users/sessions'
             }

  resources :runs, except: %i[index]
  resources :users, only: %i[show]
  resources :teams do
    resource :team_settings,
             only: %i[update],
             path: 'settings',
             as: :settings
  end
  resources :team_join_requests, only: %i[update]

  post 'remove_member', to: 'teams#remove_member'

  delete 'team_join_requests/:id/cancel',
         to: 'team_join_requests#cancel',
         as: 'cancel_request'
  patch 'team_join_requests/:id/approve',
        to: 'team_join_requests#approve',
        as: 'approve_request'
  patch 'team_join_requests/:id/reject',
        to: 'team_join_requests#reject',
        as: 'reject_request'

  post 'teams/:id/join', to: 'teams#join', as: 'join_team'
  post 'teams/:id/leave', to: 'teams#leave', as: 'leave_team'

  resource :user_settings, only: %i[update]

  root 'users#profile'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', :as => :rails_health_check
end
