# frozen_string_literal: true

module API
  module V2
    module Entities
      # User information containing profile, labels and documents
      class UserWithKYC < API::V2::Entities::Base
        expose :email,
               documentation: {
                type: 'String',
                desc: 'User Email'
               }

        expose :uid,
               documentation: {
                type: 'String',
                desc: 'User UID'
               }

        expose :role,
               documentation: {
                type: 'String',
                desc: 'User role'
               }

        expose :level,
               documentation: {
                type: 'Integer',
                desc: 'User level'
               }

        expose :otp,
               documentation: {
                type: 'Boolean',
                desc: 'is 2FA enabled for account'
               }

        expose :state,
               documentation: {
                type: 'String',
                desc: 'User state: active, pending, inactive'
               }

        expose :referral_uid,
               documentation: {
                type: 'String',
                desc: 'UID of referrer'
               } do |user|
                  user.referral_uid
               end

        expose :data,
               documentation: {
                type: 'String',
                desc: 'Additional phone and profile info'
               }

       expose :username, 
              documentation: { 
               type: 'String', 
               desc: 'User username' 
              }

        expose :profiles, using: Entities::Profile
        expose :labels, using: Entities::AdminLabelView
        expose :phones, using: Entities::Phone
        expose :documents, using: Entities::Document
        expose :data_storages, using: Entities::DataStorage
        expose :comments, using: Entities::Comment

        # activities, as sensitive and potentialy too big data should be queried separately

        with_options(format_with: :iso_timestamp) do
          expose :created_at
          expose :updated_at
        end
      end
    end
  end
end
