Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :auth0,
    'eCt7Pk3XKAAbQjq2Bu-QrGJtd4G92O1u',
    'K1lItI8rLqvfVGnjRsSWu6B4Re5Z7uWpDXz2rx3QiE8Hj_dhf1Mg6m_0sTJ8zsds',
    'barong-test.auth0.com',
    callback_path: '/auth/oauth2/callback',
    authorize_params: {
      scope: 'openid email'
    }
  )
end
