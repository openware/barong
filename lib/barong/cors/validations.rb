# frozen_string_literal: true

# Provides CORS variables validation.
module Barong
  module CORS
    # Main CORS policy logic
    module Validations
      Error = Class.new(StandardError)

      class << self
        def validate_origins(origins)
          origins.split(',').each_with_object([]) do |origin, domains|
            if origin == '*'
              Rails.logger.info { "WARNING: API_CORS_ORIGIN is set to '*'" }
              return '*'
            elsif origin.match? %r{https?:\/\/([a-zA-Z0-9]+)(\.[a-zA-Z0-9]+)*(:^[0-9]*$+)?}
              domains << origin
            else
              raise CORS::Validations::Error, "Set right origin domain name instead of #{origin}"
            end
          end
        end

        def validate_max_age(max_age)
          if max_age.present? && max_age.match?(/^[0-9]*$/)
            max_age
          else
            Rails.logger.info { 'WARNING: Incorect or missing API_CORS_MAX_AGE value. Using default value: 3600' }
            '3600'
          end
        end
      end
    end
  end
end
