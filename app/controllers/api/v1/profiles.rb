# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module API
  module V1
    class Profiles < Grape::API
      format :json

      helpers Doorkeeper::Grape::Helpers

      before do
        def profile
          @profile = Account.find_by_uid(params[:uid]).profile
        end
      end

      desc 'Profile related routes'
      resource :profile do
        desc 'Return information about profile'
        get '/' do
          profile.as_json(only: %i[first_name last_name dob address postcode city country])
        end

        desc 'Creates profile'
        params do
          requires :account_id, type: String, desc: 'ID of account'
          requires :first_name, type: String, desc: 'First name for profile'
          requires :last_name,  type: String, desc: 'Last name for profile'
          requires :dob,        type: String, desc: 'Date of birth for profile'
          requires :address,    type: String, desc: 'Address for profile'
          requires :postcode,   type: String, desc: 'Postcode for profile'
          requires :city,       type: String, desc: 'City for profile'
          requires :country,    type: String, desc: 'Country for profile'
        end
        post '/create' do
          Profile.create!(account_id: params[:account_id],
                          first_name: params[:first_name],
                          last_name:  params[:last_name],
                          dob:        params[:dob],
                          address:    params[:address],
                          postcode:   params[:postcode],
                          city:       params[:city],
                          country:    params[:country])
        end
      end
    end
  end
end
