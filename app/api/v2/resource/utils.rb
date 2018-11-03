# frozen_string_literal: true

module API::V2
  module Resource
    module Utils

      def current_user
        if env[:current_payload].has_key?(:uid)
          @_current_user ||= User.find_by!(uid: env[:current_payload][:uid])
        else
          raise(Peatio::Auth::Error, 'Middleware Error')
        end
      end

    end
  end
end
