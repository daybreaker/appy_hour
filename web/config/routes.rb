require "sidekiq/web"
require "sidekiq-cron"

Rails.application.routes.draw do
  devise_for :users

  # Sidekiq web UI — admin only
  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  # Admin dashboard
  namespace :admin do
    root to: "dashboard#index"
    resources :happy_hours, only: [ :index, :show, :update ]
    resources :venues, only: [ :index, :show, :update ]
    resources :comments, only: [ :index, :show, :update ]
    resources :reports, only: [ :index, :show, :update ]
  end

  # REST API for Expo mobile app
  namespace :api do
    namespace :v1 do
      post   "sessions", to: "sessions#create"      # login
      delete "sessions", to: "sessions#destroy"     # logout
      post   "registrations", to: "registrations#create" # sign up

      get "me", to: "users#show"

      resources :neighborhoods, only: [ :index ]

      resources :venues, only: [ :index, :show ] do
        resources :happy_hours, only: [ :create ], module: :venues
        resource :favorite, only: [ :create, :destroy ], module: :venues
      end

      resources :favorites, only: [ :index ]
    end
  end

  # Web UI (Hotwire)
  root to: "home#index"

  resources :venues, only: [ :index, :show ] do
    resources :happy_hours, only: [ :new, :create ], module: :venues
    resource :favorite, only: [ :create, :destroy ], module: :venues
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
