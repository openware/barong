 # Barong API

 Bagong API includes these routes:
 - 1. get '/api/account' - returns current account info(uid email level role state)
 - 2. post '/api/security/renew' - returns new JWT if old one is valid, otherwise,
 returns {"error":"The access token is invalid"} or {"error":"The access token expired"},
 if access token has been expired

Expiration of new JWT can also be specified by parameter 'expires_in' in seconds, otherwise,
it will look for the ENV variable JWT_LIFETIME, if both are not specified, JWT expiration
time will be set to 4 hours
- 3. post 'api/session/create' - accepts 3 params: 'email', 'password', and 'appcliation_id',
checks if they are valid, and, if they are, returns valid JWT access token.
