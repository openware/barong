Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :auth0,
    Rails.application.secrets.auth0_client_id,
    Rails.application.secrets.auth0_client_secret,
    Rails.application.secrets.auth0_domain,
    callback_path: '/api/v2/auth0/callback',
    authorize_params: {
      scope: 'openid email profile'
    }
  )
end
