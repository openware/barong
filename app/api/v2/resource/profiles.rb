# frozen_string_literal: true

module API::V2
  module Resource
    # CR functionality over profiles table
    class Profiles < Grape::API
      desc 'Profile related routes'
      resource :profiles do
        desc 'Return profile of current resource owner',
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 401, message: 'Invalid bearer token' },
               { code: 404, message: 'User has no profile' }
             ]
        get '/me' do
          error!({ errors: ['resource.profile.not_exist'] }, 404) unless current_user.profile

          current_user.profile.as_json(only: %i[first_name last_name dob address country city postcode state metadata])
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
          optional :metadata, type: Hash, desc: 'Any key:value pairs'
        end

        post do
          return error!({ errors: ['resource.profile.exist'] }, 409) unless current_user.profile.nil?

          profile = current_user.create_profile(declared(params, include_missing: false))
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
          optional :metadata, type: Hash, desc: 'Any key:value pairs'
        end

        put do
          target_profile = current_user.profile
          return error!({ errors: ['resource.profile.doesnt_exist'] }, 404) if target_profile.nil?

          unless target_profile.update(declared(params, include_missing: false))
            code_error!(target_profile.errors.details, 422)
          end

          present target_profile, with: API::V2::Entities::Profile
        end
      end
    end
  end
end
