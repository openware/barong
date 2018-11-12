module API
  class Base < Grape::API
    mount API::V2::Base => '/v2'
  end
end
