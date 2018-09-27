Doorkeeper.configure do
  # Change the ORM that doorkeeper will use (needs plugins)
  orm :active_record

  # This block will be called to check whether the resource owner is authenticated or not.
  resource_owner_authenticator do |routes|
    # Put your resource owner authentication logic here.
    # If you want to use named routes from your app you need
    # to call them on routes object eg.
    # routes.new_user_session_path
    current_account || warden.authenticate!(:scope => :account)
  end

  # If you want to restrict access to the web interface for adding oauth authorized applications, you need to declare the block below.
  admin_authenticator do
    # Put your admin authentication logic here.
    # Example implementation:
    # Admin.find_by_id(session[:admin_id]) || redirect_to(new_admin_session_url)
    #current_account || warden.authenticate!(:scope => :admin)
    redirect_to index_url unless current_account.role == 'admin'
  end

  # Authorization Code expiration time (default 10 minutes).
  # authorization_code_expires_in 10.minutes

  # Access token expiration time (default 2 hours).
  # If you want to disable expiration, set this to nil.
  expires_in = ENV.fetch('JWT_LIFETIME', 4.hours)
  if expires_in.to_i < 30.minutes || expires_in.to_i > 24.hours.to_i
    raise "JWT_LIFETIME must be from #{30.minutes} to #{24.hours.to_i} seconds"
  end

  access_token_expires_in expires_in

  # Assign a custom TTL for implicit grants.
  # custom_access_token_expires_in do |oauth_client|
  #   oauth_client.application.additional_settings.implicit_oauth_expiration
  # end

  # Use a custom class for generating the access token.
  # https://github.com/doorkeeper-gem/doorkeeper#custom-access-token-generator
  access_token_generator 'Doorkeeper::JWT'

  # The controller Doorkeeper::ApplicationController inherits from.
  # Defaults to ActionController::Base.
  # https://github.com/doorkeeper-gem/doorkeeper#custom-base-controller
  base_controller 'ApplicationController'

  # Reuse access token for the same resource owner within an application (disabled by default)
  # Rationale: https://github.com/doorkeeper-gem/doorkeeper/issues/383
  # reuse_access_token

  # Issue access tokens with refresh token (disabled by default)
  # use_refresh_token

  # Provide support for an owner to be assigned to each registered application (disabled by default)
  # Optional parameter confirmation: true (default false) if you want to enforce ownership of
  # a registered application
  # Note: you must also run the rails g doorkeeper:application_owner generator to provide the necessary support
  # enable_application_owner confirmation: false

  # Define access token scopes for your provider
  # For more information go to
  # https://github.com/doorkeeper-gem/doorkeeper/wiki/Using-Scopes
  default_scopes  :peatio, :barong

  if ENV['AUTH_SCOPES'].present?
    optional_scopes *ENV['AUTH_SCOPES'].split(',').map(&:squish)
  end

  # Change the way client credentials are retrieved from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:client_id` and `:client_secret` params from the `params` object.
  # Check out the wiki for more information on customization
  # client_credentials :from_basic, :from_params

  # Change the way access token is authenticated from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:access_token` or `:bearer_token` params from the `params` object.
  # Check out the wiki for more information on customization
  # access_token_methods :from_bearer_authorization, :from_access_token_param, :from_bearer_param

  # Change the native redirect uri for client apps
  # When clients register with the following redirect uri, they won't be redirected to any server and the authorization code will be displayed within the provider
  # The value can be any string. Use nil to disable this feature. When disabled, clients must provide a valid URL
  # (Similar behaviour: https://developers.google.com/accounts/docs/OAuth2InstalledApp#choosingredirecturi)
  #
  # native_redirect_uri 'urn:ietf:wg:oauth:2.0:oob'

  # Forces the usage of the HTTPS protocol in non-native redirect uris (enabled
  # by default in non-development environments). OAuth2 delegates security in
  # communication to the HTTPS protocol so it is wise to keep this enabled.
  #
  # force_ssl_in_redirect_uri !Rails.env.development?

  # Specify what grant flows are enabled in array of Strings. The valid
  # strings and the flows they enable are:
  #
  # "authorization_code" => Authorization Code Grant Flow
  # "implicit"           => Implicit Grant Flow
  # "password"           => Resource Owner Password Credentials Grant Flow
  # "client_credentials" => Client Credentials Grant Flow
  #
  # If not specified, Doorkeeper enables authorization_code and
  # client_credentials.
  #
  # implicit and password grant flows have risks that you should understand
  # before enabling:
  #   http://tools.ietf.org/html/rfc6819#section-4.4.2
  #   http://tools.ietf.org/html/rfc6819#section-4.4.3
  #
  # grant_flows %w(authorization_code client_credentials)

  # Under some circumstances you might want to have applications auto-approved,
  # so that the user skips the authorization step.
  # For example if dealing with a trusted application.
  skip_authorization do |resource_owner, client|
    client.application.skipauth
  end

  # WWW-Authenticate Realm (default "Doorkeeper").
  # realm "Doorkeeper"
end

Doorkeeper::JWT.configure do
  # Set the payload for the JWT token. This should contain unique information
  # about the account.
  token_payload do |opts|
    account = Account.kept.find(opts[:resource_owner_id])
    {
      iat: Time.now.to_i,
      exp: opts[:expires_in].to_i.seconds.from_now.to_i,
      sub: 'session',
      iss: 'barong',
      aud: opts[:scopes].all,

      # unique token id (for revocation purposes)
      jti: SecureRandom.hex(12).upcase,

      uid:   account.uid,
      email: account.email,
      role:  account.role,
      level: account.level,
      state: account.state,
    }
  end

  # Set the encryption secret. It's a private key and must not be shared with anybody
  ENV['JWT_PRIVATE_KEY_PATH'].tap do |pem_key|
    raise unless OpenSSL::PKey::RSA.new(File.read(pem_key)).private?
    secret_key_path pem_key
  rescue
    secret_key Base64.urlsafe_decode64(Rails.application.secrets.jwt_shared_secret_key)
  end

  # Specify encryption type. Supports any algorithim in
  # https://github.com/progrium/ruby-jwt
  encryption_method 'RS256'
end
