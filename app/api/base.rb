module API
  class Base < Grape::API
    mount API::V2::Identity::Base
    mount API::V2::Resource::Base
    mount API::V2::Management::Base
  end
end
