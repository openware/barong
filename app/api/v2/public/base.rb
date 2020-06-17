# frozen_string_literal: true

module API
  module V2
    module Public
      class Base < Grape::API
        helpers API::V2::Identity::Utils

        do_not_route_options!

        mount Public::General
      end
    end
  end
end
