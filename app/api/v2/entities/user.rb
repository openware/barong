# frozen_string_literal: true

module API
  module V2
    module Entities
      # Basic user info
      class User < API::V2::Entities::Base
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
      end
    end
  end
end
