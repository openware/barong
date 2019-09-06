# frozen_string_literal: true

module API
  module V2
    module Entities
      # Basic user info
      class User < Base
        expose :email, documentation: { type: 'String' }
        expose :uid, documentation: { type: 'String' }
        expose :role, documentation: { type: 'String' }
        expose :level, documentation: { type: 'Integer' }
        expose :otp, documentation: { type: 'Boolean', desc: 'is 2FA enabled for account' }
        expose :state, documentation: { type: 'String' }
        expose :referral_uid, documentation: { type: 'String', desc: 'UID of referrer' } do |user|
          user.referral_uid
        end
        expose :data, documentation: { type: 'String', desc: 'additional phone and profile info' }
      end
    end
  end
end
