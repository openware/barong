# frozen_string_literal: true

module API
  module V2
    module Validations
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
