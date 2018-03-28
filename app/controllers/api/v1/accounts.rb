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
        get '/' do
          current_account.as_json(only: %i[uid email level role state])
        end

        desc 'Confirms an account and set new password'
        params do
          requires :confirmation_token, type: String, desc: 'Confirmation token from email'
          requires :password, type: String, desc: 'New Password'
          requires :password_confirmation, type: String, desc: 'New Password Confirmation'
        end
        patch '/confirm' do
          current_account.confirm_by_token(params[:confirmation_token])
          if current_account.errors.any?
            return error!(current_account.errors.full_messages, 422)
          end

          current_account.update(password: params[:password],
                                 password_confirmation: params[:password_confirmation])
          if current_account.errors.any?
            return error!(current_account.errors.full_messages, 422)
          end

          'User was confirmed and password was set'
        end
      end
    end
  end
end
