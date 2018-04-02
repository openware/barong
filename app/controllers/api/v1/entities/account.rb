# frozen_string_literal: true

module API::V1::Entities
  class Account < Grape::Entity
    expose :uid,   documentation: { type: 'string', desc: 'Account identifier', example: 'ID123456789' }
    expose :email, documentation: { type: 'string', example: 'jdoe@example.io' }
    expose :level, documentation: { type: 'string', values: [0, 1, 2, 3], default: 0 }
    expose :role,  documentation: { type: 'string' }
    expose :state, documentation: { type: 'string' }
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
