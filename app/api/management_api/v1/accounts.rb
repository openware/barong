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
      end
    end
  end
end
