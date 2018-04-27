# frozen_string_literal: true

module API
  module V1
    class Sessions < Grape::API
      desc 'Session related routes'
      resource :sessions do
        desc 'Start a new session'
        params do
          requires :email
          requires :password
          requires :application_id
          optional :expires_in, allow_blank: false
        end

        post do
          declared_params = declared(params, include_missing: false)
          acc = Account.find_by(email: declared_params[:email])

          return error!('Invalid Email or password.', 401) unless acc

          app = Doorkeeper::Application.find_by(uid: declared_params[:application_id])
          return error!('Wrong application id', 401) unless app

          if acc.valid_password? declared_params[:password]
            Barong::Security::AccessToken.create declared_params[:expires_in], acc.id, app
          else
            error!('Invalid Email or password.', 401)
          end
        end
      end
    end
  end
end
