# frozen_string_literal: true

module API
  module V2
    module Auth0
      # base api configurations for module
      class Base < Grape::API
        do_not_route_options!

        mount Auth0::Sessions
        mount Auth0::Callback
      end
    end
  end
end
