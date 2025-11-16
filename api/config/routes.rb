Rails.application.routes.draw do
  devise_for :users

  namespace :api do
    namespace :v1 do
      devise_for :users,
        defaults: { format: :json },
        path: '', # keep clean URLs under /api/v1
        path_names: {
          sign_in:  'session',   # POST   /api/v1/session
          sign_out: 'session',   # DELETE /api/v1/session
          registration: 'users'  # POST   /api/v1/users
        },
        controllers: {
          sessions:       'api/v1/users/sessions',
          registrations:  'api/v1/users/registrations'
        }

      # React-Admin friendly CRUD (flat resources)
      resources :venues
      resources :menus
      resources :hours
      resources :menu_items
      resources :menu_item_deals

      # Example protected endpoint to test
      get "up" => "rails/health#show", as: :rails_health_check
    end
  end
end
