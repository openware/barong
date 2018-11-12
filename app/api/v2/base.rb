module API::V2
    class Base < Grape::API
        mount Identity::Base   => '/identity'
        mount Resource::Base   => '/resource'
        mount Management::Base => '/management'
    end
  end
