Rails.application.routes.draw do
  match '/api/v2/auth/*path', to: AuthorizeController.action(:authorize), via: :all

  unless Barong::ProviderPolicy.config.provider == 'native'
    get '/api/v2/login', to: redirect("/auth/#{Barong::ProviderPolicy.config.provider}")
  end

  get 'auth/:provider/callback', to: 'sessions#create'
  mount API::Base, at: '/api'
end
