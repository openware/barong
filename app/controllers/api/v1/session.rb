# frozen_string_literal: true

require 'barong/security/access_token'

module API
  module V1
    class Session < Grape::API
      desc 'Session related routes'
      resource :session do
        post '/create' do
          acc = Account.find_by(email: params[:email])
          return error!('401 Unauthorized', 401) unless acc

          app = Doorkeeper::Application.find_by(uid: params[:application_id])
          return error!('401 Unauthorized Application', 401) unless app

          if acc.valid_password? params[:password]
            Barong::Security::AccessToken.create params[:expires_in], acc.id, app
          else
            error!('401 Unauthorized', 401)
          end
        end
      end
    end
  end
end
