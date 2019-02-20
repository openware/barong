# frozen_string_literal: true

module API
  module V2
    module Validations

      class AllowBlankValidator < Grape::Validations::AllowBlankValidator
        # Default exception is costructed from `@api` class name.
        # E.g
        # @api.base.name  => API::V2::Account::Withdraws
        # default_message => "account.withdraw.missing_otp"
        def message(_param)
          api = @scope.instance_variable_get(:@api)
          module_name = api.base.parent.name.humanize.demodulize
          class_name = api.base.name.humanize.demodulize.singularize
          # Return default API error message for Management module (no errors unify).
          return super if module_name == 'management'

          options_key?(:message) ? @option[:message] : default_exception(module_name, class_name)
        end

        def default_exception(module_name, class_name)
          "#{module_name}.#{class_name}.empty_#{attrs.first}"
        end
      end

      class PresenceValidator < Grape::Validations::PresenceValidator
        # Default exception is costructed from `@api` class name.
        # E.g
        # @api.base.name  => API::V2::Account::Withdraws
        # default_message => "account.withdraw.missing_otp"

        def message(_param)
          api = @scope.instance_variable_get(:@api)
          module_name = api.base.parent.name.humanize.demodulize
          class_name = api.base.name.humanize.demodulize.singularize
          # Return default API error message for Management module (no errors unify).
          return super if module_name == 'management'

          options_key?(:message) ? @option[:message] : default_exception(module_name, class_name)
        end

        def default_exception(module_name, class_name)
          "#{module_name}.#{class_name}.missing_#{attrs.first}"
        end
      end

      # Range validation for pagination tool
      class Range < Grape::Validations::Base
        def initialize(*)
          super
          @range = @option
        end

        def validate_param!(attr, params)
          return unless (params[attr] || @required) && !@range.cover?(params[attr])

          raise Grape::Exceptions::Validation, \
            params:  [@scope.full_name(attr)],
            message: "must be in range: #{@range}."
        end
      end

      # Greater then zero validation for integers
      class IntegerGTZero < Grape::Validations::Base
        def validate_param!(name, params)
          return unless params.key?(name)
          return if params[name].to_s.to_i.positive?

          raise Grape::Exceptions::Validation,
              params:  [@scope.full_name(name)],
              message: "#{name} must be greater than zero."
        end
      end
    end
  end
end
