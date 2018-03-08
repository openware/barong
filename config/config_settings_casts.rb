# frozen_string_literal: true

require 'ostruct'

Barong.config.cast(:email) do |value|
  EmailSchema = Dry::Validation.Schema do
    required('default_from').filled(format?: Devise.email_regexp)
    required('admin').filled(format?: Devise.email_regexp)
  end
  result = EmailSchema.call(value)
  raise result.hints if result.failure?

  OpenStruct.new(value)
end
