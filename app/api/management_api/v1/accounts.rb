# frozen_string_literal: true

module ManagementAPI
  module V1
    class Accounts < Grape::API
      desc 'Account related routes'
      resource :accounts do
        desc 'Get account and profile information' do
          @settings[:scope] = :read_accounts
          success Entities::AccountWithProfile
        end

        params do
          requires :uid, type: String, allow_blank: false, desc: 'Account uid'
        end

        post '/get' do
          account = Account.kept.find_by!(declared(params))
          present account, with: Entities::AccountWithProfile
        end

        desc 'Creates new account' do
          @settings[:scope] = :write_accounts
          success Entities::AccountWithProfile
        end

        params do
          requires :email, type: String, desc: 'Account Email', allow_blank: false
          requires :password, type: String, desc: 'Account Password', allow_blank: false
        end

        post do
          account = Account.create(declared(params))
          error!(account.errors.full_messages, 422) unless account.persisted?
          present account, with: Entities::AccountWithProfile
        end

        desc 'Imports an existing account' do
          @settings[:scope] = :write_accounts
          success Entities::AccountWithProfile
        end

        params do
          requires :email, type: String,
                           desc: 'Account Email',
                           allow_blank: false
          requires :password_hash, type: String,
                                   desc: 'Account Password Hash',
                                   allow_blank: false
        end

        post do
          account = Account.new(email: params[:email],
                                encrypted_password: params[:password_hash])
          account.assign_uid
          account.save(validate: false)
          error!(account.errors.full_messages, 422) unless account.persisted?
          account.confirm
          present account, with: Entities::AccountWithProfile
        end
      end
    end
  end
end
