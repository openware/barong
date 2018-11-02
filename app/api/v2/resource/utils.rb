# frozen_string_literal: true

module API::V2
  module Resource
    module Utils

      def current_user
        env[:current_user]
      end

    end
  end
end
