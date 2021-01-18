# frozen_string_literal: true

require_dependency 'barong/jwt'

module API::V2
  module Auth0
    class Sessions < Grape::API
      desc 'Session related routes'
      resource :sessions do
        desc 'Start a new session',
          failure: [
            { code: 400, message: 'Required params are empty' },
            { code: 404, message: 'Record is not found' }
        ]
        params do
          requires :email
          requires :password
        end
        post do
          status(200)
        end
      end
    end
  end
end
