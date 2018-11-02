# frozen_string_literal: true

module API::V2
    module Management
      module Exceptions
        class Authentication < Base
          def status
            @options.fetch(:status, 401)
          end
        end
      end
    end
  end
