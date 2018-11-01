module API
  class Base < Grape::API
    mount API::V2::Identity::Base
  end
end
