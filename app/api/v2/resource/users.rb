# frozen_string_literal: true

module API::V2
  module Resource
    class Users < Grape::API
      resource :users do
        desc 'Test connectivity'
        get '/me' do
          env['_current_user']
        end
      end
    end
  end
end
