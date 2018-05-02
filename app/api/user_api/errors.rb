module UserApi
  class AuthorizationError < StandardError
    def initialize(message = 'Authorization failed')
      super
    end
  end
end
