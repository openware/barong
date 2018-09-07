# frozen_string_literal: true

module ManagementAPI
  module V1
    class Accounts < Grape::API
      helpers do
        def profile_param_keys
          %w[first_name last_name dob address
             postcode city country].freeze
        end

        def create_account(account_params)
          account = Account.new(account_params)
          account.assign_uid
          account.save(validate: false)
          error!(account.errors.full_messages, 422) unless account.persisted?
          account.confirm

          account
        end

        def all_profile_fields?(params)
          profile_param_keys.all? { |key| params[key].present? }
        end

        def create_profile(account:, params:)
          return unless all_profile_fields?(params)
          profile = account.create_profile(params)
          error!(profile.errors.full_messages, 422) unless profile.persisted?
        end

        def create_phone(account:, number:)
          return if number.blank?

          phone = account.phones.create(number: number)
          error!(phone.errors.full_messages, 422) unless phone.persisted?
          phone.update(validated_at: Time.current)
        end
      end

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
          optional :phone, type: String, allow_blank: false
          optional :first_name, type: String, allow_blank: false
          optional :last_name, type: String, allow_blank: false
          optional :dob, type: Date, desc: 'Birthday date', allow_blank: false
          optional :address, type: String, allow_blank: false
          optional :postcode, type: String, allow_blank: false
          optional :city, type: String, allow_blank: false
          optional :country, type: String, allow_blank: false
        end

        post '/import' do
          if Account.kept.find_by(email: params[:email]).present?
            error! 'Account already exists by this email', 422
          end

          account = create_account(email: params[:email],
                                   encrypted_password: params[:password_hash])
          create_phone(account: account, number: params[:phone])

          profile_params = params.slice(*profile_param_keys)
          create_profile(account: account, params: profile_params)

          present account, with: Entities::AccountWithProfile
        end
      end
    end
  end
end
