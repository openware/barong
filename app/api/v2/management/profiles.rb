# frozen_string_literal: true

module API::V2
  module Management
    # Profiles server-to-server API
    class Profiles < Grape::API
      desc 'Profiles related routes'
      resource :profiles do
        helpers do
          def profile_param_keys
            %w[first_name last_name dob address
               postcode city country state metadata].freeze
          end
        end

        desc 'Imports a profile for user' do
          @settings[:scope] = :write_users
          success API::V2::Management::Entities::UserWithProfile
        end

        params do
          requires :uid, type: String, desc: 'User Uid', allow_blank: false
          optional :first_name, type: String, desc: 'First Name', allow_blank: false
          optional :last_name, type: String, desc: 'Last Name', allow_blank: false
          optional :dob, type: Date, desc: 'Birth date', allow_blank: false
          optional :address, type: String, desc: 'Address', allow_blank: false
          optional :postcode, type: String, desc: 'Postcode', allow_blank: false
          optional :city, type: String, desc: 'City', allow_blank: false
          optional :country, type: String, desc: 'Country', allow_blank: false
          optional :state, type: String, desc: 'State', allow_blank: false
          optional :metadata, type: String, desc: 'Metadata', allow_blank: false
        end

        post do
          user = User.find_by(uid: params[:uid])
          error! 'user.doesnt_exist', 422 unless user

          profile_params = params.slice(*profile_param_keys)
          profile = Profile.new(profile_params.merge(user_id: user.id))
          error!(profile.errors.full_messages, 422) unless profile.save

          present user, with: API::V2::Management::Entities::UserWithProfile
        end
      end
    end
  end
end
