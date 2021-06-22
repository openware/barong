# frozen_string_literal: true

module API
  module V2
    module Entities
      # User information containing profile, labels and documents
      class UserWithFullInfo < API::V2::Entities::Base
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

        expose :csrf_token,
               documentation: {
                type: 'String',
                desc: 'Сsrf protection token'
               },
               if: ->(_, options) { options[:csrf_token] } do |_user, options|
                options[:csrf_token]
               end

       expose :username, 
              documentation: { 
               type: 'String', 
               desc: 'User username' 
              }

        expose :labels, using: Entities::Label
        expose :phones, using: Entities::Phone
        expose :profiles, using: Entities::Profile
        expose :data_storages, using: Entities::DataStorage
        # activities, as sensitive and potentialy too big data should be queried separately

        with_options(format_with: :iso_timestamp) do
          expose :created_at
          expose :updated_at
        end
      end
    end
  end
end
