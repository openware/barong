# frozen_string_literal: true

require_dependency 'barong/jwt'

module API::V2
  module Auth0
    class Callback < Grape::API
      desc 'Callback related routes'
      resource :callback do
        desc 'Retrive callback from auth0',
        failure: [
            { code: 400, message: 'Required params are missing' },
            { code: 422, message: 'Validation errors' }
          ]
        params do
            optional :email
        end
        post do
          session[:userinfo] = request.env['omniauth.auth']
          status(200)
        end
      end
    end
  end
end
