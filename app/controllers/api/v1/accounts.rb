# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module API
  module V1
    class Accounts < Grape::API
      helpers Doorkeeper::Grape::Helpers

      desc 'Account related routes'
      resource :account do
        desc 'Creates new account'
        params do
          requires :email, type: String, desc: 'Account Email'
          requires :password, type: String, desc: 'Account Password'
        end
        post do
          account = Account.create(email: params[:email], password: params[:password])
          error!(account.errors.full_messages, 422) unless account.persisted?
        end

        namespace do
          before do
            doorkeeper_authorize!

            def current_account
              @current_account = Account.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
            end
          end

          desc 'Return information about current resource owner'
          get '/' do
            current_account.as_json(only: %i[uid email level role state])
          end

          desc 'Confirms an account'
          params do
            requires :confirmation_token, type: String, desc: 'Confirmation token from email'
          end
          patch '/confirm' do
            account = Account.find_first_by_auth_conditions confirmation_token: params[:confirmation_token]
            return error!('Confirmation token is invalid', 422) if account != current_account
            error!('Account is already confirmed', 422) unless current_account.confirm
          end
        end
      end
    end
  end
end
