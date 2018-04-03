# frozen_string_literal: true

module API::V1::Entities
  class Account < Grape::Entity
    expose :uid,   documentation: { type: 'string', desc: 'Account identifier', example: 'ID123456789' }
    expose :email, documentation: { type: 'string', desc: 'Account\'s email', example: 'jdoe@example.io' }
    expose :level, documentation: { type: 'string', desc: 'Account level, email confirmation -> 1 level, phone verification -> 2 level, document verification -> 3 level', values: [0, 1, 2, 3], default: 0 }
    expose :role,  documentation: { type: 'string', desc: 'Role can be member, admin, compliance' }
    expose :state, documentation: { type: 'string', desc: 'The default state of account is "pending",also can be "active", "frozen" etc' }
  end

  class AccountParams < Grape::Entity
    expose :email,
      documentation: {
        desc: 'Account email',
        required: true,
        param_type: 'body',
        type: 'string',
        example: 'jdoe@example.io'
      }

    expose :password,
      documentation: {
        desc: 'Raw (not encoded) account password',
        required: true,
        param_type: 'body',
        type: 'string',
        example: '12345678'
      }
  end
end
