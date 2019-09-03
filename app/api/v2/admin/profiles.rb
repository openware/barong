# frozen_string_literal: true

module API
  module V2
    module Admin
      # Admin functionality over profiles table
      class Profiles < Grape::API
        resource :profiles do

          desc 'Return all profiles',
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 401, message: 'Invalid bearer token' },
             ]
          params do
            optional :page,
                     type: { value: Integer, message: 'admin.profiles.non_integer_page' },
                     values: { value: -> (p){ p.try(:positive?) }, message: 'admin.profiles.non_positive_page'},
                     default: 1,
                     desc: 'Page number (defaults to 1).'
            optional :limit,
                     type: { value: Integer, message: 'admin.profiles.non_integer_limit' },
                     values: { value: 1..100, message: 'admin.profiles.invalid_limit' },
                     default: 100,
                     desc: 'Number of profiles per page (defaults to 100, maximum is 100).'
          end

          get do
            present paginate(Profile.all), with: API::V2::Entities::Profile
          end

          desc 'Update a profile for user',
          security: [{ "BearerToken": [] }],
          failure: [
            { code: 400, message: 'Required params are empty' },
            { code: 401, message: 'Invalid bearer token' },
            { code: 422, message: 'Validation errors' }
          ]
          params do
            requires :id, type: Integer
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
            target_profile = Profile.find_by(id: params[:id])
            return error!({ errors: ['admin.profiles.doesnt_exist'] }, 404) if target_profile.nil?

            unless target_profile.update(declared(params, include_missing: false))
              code_error!(target_profile.errors.details, 422)
            end

            present target_profile, with: API::V2::Entities::Profile
          end

          desc 'Delete a profile for user',
          security: [{ "BearerToken": [] }],
          failure: [
            { code: 400, message: 'Required params are empty' },
            { code: 401, message: 'Invalid bearer token' },
            { code: 422, message: 'Validation errors' }
          ]
          params do
            requires :id, type: Integer
          end

          delete do
            target_profile = Profile.find_by(id: params[:id])
            return error!({ errors: ['admin.profiles.doesnt_exist'] }, 404) if target_profile.nil?

            present target_profile.destroy, with: API::V2::Entities::Profile
          end
        end
      end
    end
  end
end
