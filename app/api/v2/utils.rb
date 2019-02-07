# frozen_string_literal: true

module API
  module V2
    # provides all general (shared for all the modules) helper funcs
    module Utils
      def code_error!(errors, code)
        final = errors.inject([]) do |result, (key, errs)|
          result.concat(
            errs.map { |e| e.values.first }
                  .uniq
                  .flatten
                  .map { |e| [key, e].join('.') }
          )
        end
        error!({ errors: final }, code)
      end
    end
  end
end
