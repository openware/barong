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
        end

        post do
          profile = current_user.profiles.create(declared(params, include_missing: false))
          code_error!(profile.errors.details, 422) if profile.errors.any?
          # labels
          # current_user.labels.create(key: 'profile', value: 'drafted', scope: 'private')

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
        end

        put do
          target_profile = current_user.profiles.find_by(state: 'drafted')  
          return error!({ errors: ['resource.profile.doesnt_exist_or_not_editable'] }, 404) if target_profile.nil?

          unless target_profile.update(declared(params, include_missing: false))
            code_error!(target_profile.errors.details, 422)
          end
          present target_profile, with: API::V2::Entities::Profile
        end
      end
    end
  end
end
