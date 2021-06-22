# frozen_string_literal: true

module API::V2
  module Management
    class Users < Grape::API
      helpers ::API::V2::NamedParams
      helpers do
        def profile_param_keys
          %w[first_name last_name dob address
             postcode city country state].freeze
        end

        def create_user(user_params)
          user = User.new(user_params)
          user.send :assign_uid
          user.save(validate: false)
          error!(user.errors.full_messages3, 422) unless user.persisted?
          user
        end

        def all_profile_fields?(params)
          profile_param_keys.all? { |key| params[key].present? }
        end

        def create_phone(user:, number:)
          return if number.blank?

          phone = user.phones.create(number: number)
          error!(phone.errors.full_messages, 422) unless phone.persisted?
          phone.update(validated_at: Time.current)
        end
      end

      desc 'Users related routes'
      resource :users do
        desc 'Get users and profile information' do
          @settings[:scope] = :read_users
          success API::V2::Management::Entities::UserWithKYC
        end
        params do
          optional :uid, type: String, allow_blank: false, desc: 'User uid'
          optional :email, type: String, allow_blank: false, desc: 'User email'
          optional :phone_num, type: String, allow_blank: false, desc: 'User phone number'
          exactly_one_of :uid, :email, :phone_num
        end
        post '/get' do
          declared_params = declared(params, include_missing: false)

          if declared_params.key?(:phone_num)
            user = Phone.find_by_number!(declared_params[:phone_num]).user
            present user, with: API::V2::Management::Entities::UserWithKYC
            return status 201
          end

          user = User.find_by!(declared_params)
          present user, with: API::V2::Management::Entities::UserWithKYC
        end

        desc 'Returns array of users as collection',
        security: [{ "BearerToken": [] }],
        failure: [
          { code: 401, message: 'Invalid bearer token' }
        ] do
          @settings[:scope] = :read_users
          success API::V2::Entities::User
        end
        params do
          optional :extended,
                   type: { value: Boolean, message: 'Non boolean extended value' },
                   default: false,
                   desc: 'When true endpoint returns full information about users'
          optional :range,
                   type: String,
                   values: { value: -> (p){ %w[created updated].include?(p) }, message: 'Non positive page' },
                   default: 'created'
          use :timeperiod_filters
          use :pagination_filters
        end
        post '/list' do
          entity = params[:extended] ? API::V2::Management::Entities::UserWithProfile : API::V2::Entities::User
          users = API::V2::Queries::UserFilter.new(User.all).call(params)
          users.tap { |q| present paginate(q), with: entity }
          status 200
        end

        desc 'Creates new user' do
          @settings[:scope] = :write_users
          success API::V2::Management::Entities::UserWithProfile
        end
        params do
          requires :email, type: String, desc: 'User Email', allow_blank: false
          requires :password, type: String, desc: 'User Password', allow_blank: false
          optional :referral_uid, type: String, desc: 'Referral uid', allow_blank: false
        end
        post do
          referral = User.find_by_uid(params[:referral_uid]).id if params[:referral_uid]

          user = User.create({ email: params[:email], password: params[:password], referral_id: referral }.compact )

          error!(user.errors.full_messages, 422) unless user.persisted?
          present user, with: API::V2::Management::Entities::UserWithProfile
        end

        desc 'Updates role and data fields of existing user' do
          @settings[:scope] = :write_users
          success API::V2::Management::Entities::UserWithProfile
        end
        params do
          requires :uid, type: String, desc: 'User Uid', allow_blank: false
          optional :role, type: String, desc: 'User Role', allow_blank: false
          optional :data, type: String, desc: 'Any additional key:value pairs in json format', allow_blank: false
          at_least_one_of :role, :data
        end
        post '/update' do
          user = User.find_by_uid(params[:uid])
          error! 'user.doesnt_exist', 422 unless user

          u_params = { data: params[:data], role: params[:role] }.compact
          error!(user.errors.full_messages, 422) unless user.update(u_params)

          present user, with: API::V2::Management::Entities::UserWithProfile
        end

        desc 'Imports an existing user' do
          @settings[:scope] = :write_users
          success API::V2::Management::Entities::UserWithProfile
        end
        params do
          requires :email, type: String,
                           desc: 'User Email',
                           allow_blank: false
          requires :password_digest, type: String,
                                     desc: 'User Password Hash',
                                     allow_blank: false
          optional :referral_uid, type: String, desc: 'Referral uid', allow_blank: false
          optional :phone, type: String, allow_blank: false, desc: 'Phone'
          optional :first_name, type: String, allow_blank: false, desc: 'First Name'
          optional :last_name, type: String, allow_blank: false, desc: 'Last Name'
          optional :dob, type: Date, desc: 'Birth date', allow_blank: false
          optional :address, type: String, allow_blank: false, desc: 'Address'
          optional :postcode, type: String, allow_blank: false, desc: 'Postcode'
          optional :city, type: String, allow_blank: false, desc: 'City'
          optional :country, type: String, allow_blank: false, desc: 'Country'
          optional :state, type: String, allow_blank: false, desc: 'State'
        end
        post '/import' do
          if User.find_by(email: params[:email]).present?
            error! 'User already exists by this email', 422
          end

          referral = User.find_by_uid(params[:referral_uid]).id if params[:referral_uid]
          user = create_user({
            email: params[:email],
            password_digest: params[:password_digest],
            referral_id: referral
          }.compact)
          create_phone(user: user, number: params[:phone])

          profile_params = params.slice(*profile_param_keys)
          profile = Profile.new(profile_params.merge(user_id: user.id))
          error!(profile.errors.full_messages, 422) unless profile.save

          present user, with: API::V2::Management::Entities::UserWithProfile
        end
      end
    end
  end
end
