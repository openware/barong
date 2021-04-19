Rails.application.routes.draw do
  match '/api/v2/auth/*path', to: AuthorizeController.action(:authorize), via: :all
  match '/api/v2/token/*path', to: AuthorizeController.action(:token), via: :all
  mount API::Base, at: '/api'
end
