# frozen_string_literal: true

module UserApi
  class Base < Grape::API
    mount UserApi::V1::Base
  end
end
