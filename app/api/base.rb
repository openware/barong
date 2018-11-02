module API
  class Base < Grape::API
    mount API::V2::Identity::Base
    mount API::V2::Resource::Base
  end
end
