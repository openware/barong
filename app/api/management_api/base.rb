# frozen_string_literal: true

module ManagementAPI
  class Base < Grape::API
    mount ManagementAPI::V1::Base
  end
end
