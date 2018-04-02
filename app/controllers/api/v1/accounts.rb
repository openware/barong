# frozen_string_literal: true

require_dependency 'doorkeeper/grape/helpers'

module API
  module V1
    class Accounts < Grape::API
      format :json
      content_type :json, 'application/json'
      default_format :json

      helpers Doorkeeper::Grape::Helpers

      desc 'Register new accounts and get current account data'
      resource :accounts do
        namespace do
          before do
            doorkeeper_authorize!

            def current_account
              @current_account = Account.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
            end
          end

          desc 'Get current account info', {
            nickname: 'me',
            success: Entities::Account,
            detail: <<~DOC
              This endpoint returns account data without profile data like name or city.
            DOC
          }
          get '/me' do
            present current_account, with: Entities::Account
          end
        end

        desc 'Register a new account' do
          params Entities::AccountParams.documentation
          detail <<~DOC
            After account is saved to the database, Barong will trigger an email with
            confirmation link.
          DOC

          @settings[:nickname] = 'signup'
          @settings[:body_name] = 'accountParams'
        end
        post do
          account = Account.create(email: params[:email], password: params[:password])
          error!(account.errors.full_messages, 422) unless account.persisted?
        end
      end
    end
  end
end
