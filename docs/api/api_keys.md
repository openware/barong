# API Keys

## How does it work?

To be available to send requests to the [peatio api](https://github.com/rubykube/peatio/blob/1-8-stable/docs/api/member_api_v2.md) you need to send proper JWT (JSON Web Token) signed by Barong.
Only Barong can sign valid token.

The user must have 2FA enabled before using API Keys.
You need to provide valid TOTP code on api key access.

### API Key flow:
1. Create an api key with a `public key`, `scopes` and `expired_in`. `expired_in` is an optional. Default value is 24 hours. To generate keypair with your public and private key, please use this command

   ```bash
   # You can generate keypair using:
   ruby -e "require 'openssl'; require 'base64'; OpenSSL::PKey::RSA.generate(2048).tap { |p| puts '', 'PRIVATE RSA KEY (URL-safe Base64 encoded, PEM):', '', Base64.urlsafe_encode64(p.to_pem), '', 'PUBLIC RSA KEY (URL-safe Base64 encoded, PEM):', '', Base64.urlsafe_encode64(p.public_key.to_pem) }"
   ```

   To create an api key, you need to use [POST /api/v1/api_keys](https://github.com/rubykube/barong/blob/1-8-stable/docs/api/api.md#postv1apikeys)

   Example:

   ```bash
   curl -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer {jwt_access_token}" -d '{"public_key":"", "totp_code":"...", "scopes":"..."}' https://localhost:3000/api/v1/api_keys
   ```

2. To retrieve an access token a valid payload should be sent to barong, it must be signed with the private key
 The request is a [POST /api/v1/sessions/generate_jwt](https://github.com/rubykube/barong/blob/1-8-stable/docs/api/api.md#postv1sessionsgeneratejwt)

   Example:

   ```bash
   curl -X POST -H 'Content-Type: application/json' -d '{"kid":"...", "jwt_token":"..."}' http://localhost:3000/api/v1/sessions/generate_jwt
   ```

   Parameters:

   ```yaml
   'kid': uid of the api_key
   'jwt_token': payload with signature
   ```

   Example of prapring a signed payload:
   
   ```ruby
   require 'openssl'
   require 'base64'
   require 'json'
   require 'securerandom'
   require 'jwt'
   require 'active_support/time'
   
   secret_key = OpenSSL::PKey.read(Base64.urlsafe_decode64('private_key))
   payload = {
     iat: Time.current.to_i,
     exp: 20.minutes.from_now.to_i,
     sub: 'api_key_jwt',
     iss: 'external',
     jti: SecureRandom.hex(12).upcase
   }
   jwt_token = JWT.encode(payload, secret_key, 'RS256')
   ```

3. Send this signature (as `jwt_token` parameter) to barong with the associated API key id (`kid`), Barong returns a valid JWT.

4. Use the JWT to access to peatio API. The token will be expired after `expired_in` time. After that you can generate a new JWT folloings steps from 2.
