module API
  class Base < Grape::API
    PREFIX = '/api'

    cascade false

    mount API::V2::Base => API::V2::Base::API_VERSION
  end
end
