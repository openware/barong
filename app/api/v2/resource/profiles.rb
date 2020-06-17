# frozen_string_literal: true

module API::V2
  module Resource
    # CR functionality over profiles table
    class Profiles < Grape::API
      helpers do
        def profile_param_keys
          %w[first_name last_name dob address
             postcode city country metadata].freeze
        end
      end

      desc 'Profile related routes'
      resource :profiles do
        desc 'Return profiles of current resource owner',
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 401, message: 'Invalid bearer token' },
               { code: 404, message: 'User has no profile' }
             ]
        get '/me' do
          present current_user.profiles, with: API::V2::Entities::Profile
        end

        desc 'Create a profile for current_user',
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 409, message: 'Profile already exists' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          optional :first_name, type: String
          optional :last_name, type: String
          optional :dob, type: Date
          optional :address, type: String
          optional :postcode, type: String
          optional :city, type: String
          optional :country, type: String
          optional :metadata, type: String, desc: 'Any additional key: value pairs in json string format'
          optional :confirm, type: Boolean, default: false, desc: 'Profile confirmation'
        end

        post do
          declared_params = declared(params.slice(*profile_param_keys), include_missing: false)
          declared_params.merge!(state: 'submitted') if params['confirm']

          profile = current_user.profiles.create(declared_params)
          code_error!(profile.errors.details, 422) if profile.errors.any?

          present profile, with: API::V2::Entities::Profile
          status 201
        end

        desc 'Update a profile for current_user',
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 401, message: 'Invalid bearer token' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          optional :first_name, type: String
          optional :last_name, type: String
          optional :dob, type: Date
          optional :address, type: String
          optional :postcode, type: String
          optional :city, type: String
          optional :country, type: String
          optional :metadata, type: String, desc: 'Any additional key: value pairs in json string format'
          optional :confirm, type: Boolean, default: false, desc: 'Profile confirmation'
        end

        put do
          target_profile = current_user.drafted_profile
          return error!({ errors: ['resource.profile.doesnt_exist_or_not_editable'] }, 404) if target_profile.nil?

          declared_params = declared(params.slice(*profile_param_keys), include_missing: false)
          declared_params.merge!(state: 'submitted') if params['confirm']

          code_error!(target_profile.errors.details, 422) unless target_profile.update(declared_params)

          present target_profile, with: API::V2::Entities::Profile
        end
      end
    end
  end
end
