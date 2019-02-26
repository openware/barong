# frozen_string_literal: true

module API
  module V2
    module Identity
      # base api configurations for module
      class Base < Grape::API
        helpers API::V2::Identity::Utils

        do_not_route_options!

        mount Identity::General
        mount Identity::Sessions
        mount Identity::Users
      end
    end
  end
end
