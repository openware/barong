# frozen_string_literal: true

module API::V2
  module Resource
    class Users < Grape::API
      resource :users do
        desc 'Returns current user'
        get '/me' do
          current_user.attributes.except('password_digest')
        end
      end
    end
  end
end
