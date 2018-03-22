# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module API
  class Base < Grape::API
    helpers Doorkeeper::Grape::Helpers

    mount API::V1::Base
  end
end
