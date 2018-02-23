# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module API
  module V1
    class Profiles < Grape::API
      format :json

      desc 'Creates new profile'
      resource :profile do
        params do
          requires :uid,        type: String, desc: 'UID of account'
          requires :first_name, type: String, desc: 'First name for profile'
          requires :last_name,  type: String, desc: 'Last name for profile'
          requires :dob,        type: String, desc: 'Date of birth for profile'
          requires :address,    type: String, desc: 'Address for profile'
          requires :postcode,   type: String, desc: 'Postcode for profile'
          requires :city,       type: String, desc: 'City for profile'
          requires :country,    type: String, desc: 'Country for profile'
        end
        post '/create' do
          profile = Profile.create(account_id: Account.find_by_uid(params[:uid]).id,
                                   first_name: params[:first_name],
                                   last_name:  params[:last_name],
                                   dob:        params[:dob],
                                   address:    params[:address],
                                   postcode:   params[:postcode],
                                   city:       params[:city],
                                   country:    params[:country])
          profile.save
        end
      end
    end
  end
end
