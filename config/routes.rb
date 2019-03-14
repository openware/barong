Rails.application.routes.draw do
  # match '/api/v2/auth/*path', to: AuthorizeController.action(:authorize), via: :all
  # mount API::Base, at: '/api'
  namespace :api do
    namespace :v3 do
      namespace :admin do
        resources :users
      end
    end
  end
end
