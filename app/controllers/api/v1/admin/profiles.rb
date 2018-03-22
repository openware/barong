# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module API
  module V1
    module Admin
      class Profiles < Grape::API
        desc 'Profiles related routes'
        resource :profile do
          desc 'Return all profiles'
          get '/' do
            authorize! :manage, Profile
            Profile.all.as_json(only: %i[first_name last_name dob address postcode city country state])
          end

          desc 'Update state of profile'
          post '/set_state' do
            authorize! :manage, Profile
            Profile.find_by_id(params[:id]).update(state: params[:state])
          end
        end
      end
    end
  end
end
