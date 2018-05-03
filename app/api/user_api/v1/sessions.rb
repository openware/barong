# frozen_string_literal: true

module UserApi
  module V1
    class Sessions < Grape::API
      desc 'Session related routes'
      resource :sessions do
        desc 'Start a new session'
        params do
          requires :email, type: String, desc: 'Sessions Email', allow_blank: false
          requires :password, type: String, desc: 'Sessions Password', allow_blank: false
          optional :expires_in, type: Integer, desc: 'Expires in(seconds)', allow_blank: false
        end

        post do
          declared_params = declared(params, include_missing: false)
          account = Account.find_by(email: declared_params[:email])

          unless account&.valid_password? declared_params[:password]
            error!('Invalid Email or password.', 401)
          end

          Barong::Security::AccessToken.generate_jwt(account_uid: account.uid,
                                                     expires_in: params[:expires_in])
        end
      end
    end
  end
end
