# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module API
  module V1
    class Accounts < Grape::API
      helpers Doorkeeper::Grape::Helpers

      before do
        doorkeeper_authorize!

        def current_account
          @current_account = Account.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
        end
      end

      desc 'Account related routes'
      resource :account do
        desc 'Return information about current resource owner'
        get '/show' do
          current_account.as_json(only: %i[uid email level role state])
        end

        desc 'Create account'
        params do
          requires :email, type: String, desc: 'Account email'
          requires :password, type: String, desc: 'Account password'
        end
        post '/new' do
          email = params[:email]
          password = params[:password]
          account = Account.create!(email: email.downcase, password: password)

          if account.valid?
            account.save
            return account
          else
            error!(message: 'Invalid email or password', status: 500)
          end  
        end
      end
    end
  end
end
