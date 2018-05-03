# API Keys

## Configuration

```yml
# JWT configuration.
# You can generate keypair using:
#
#   ruby -e "require 'openssl'; require 'base64'; OpenSSL::PKey::RSA.generate(2048).tap { |p| puts '', 'PRIVATE RSA KEY (URL-safe Base64 encoded, PEM):', '', Base64.urlsafe_encode64(p.to_pem), '', 'PUBLIC RSA KEY (URL-safe Base64 encoded, PEM):', '', Base64.urlsafe_encode64(p.public_key.to_pem) }"
#
```

Then you need to use [api keys api](https://github.com/rubykube/barong/blob/master/docs/index.md#api_keys)
to create api key with generated public key.

Then you use [session generate jwt api](https://github.com/rubykube/barong/blob/master/docs/index.md#postv1sessionsgeneratejwt).
The api required key uid and jwt token.
Key uid you can find by `GET /v1/api_keys` request.

You encode payload that contains `key_uid` itself with folowing code
```
secret_key = OpenSSL::PKey.read(Base64.urlsafe_decode64('private_key))
payload = {
  key_uid: 'api_key_uid',
  iat: Time.current.to_i,
  exp: 1.minute.from_now.to_i,
  sub: 'api_key_jwt',
  iss: 'external',
  jti: SecureRandom.hex(12).upcase
}
jwt_token = JWT.encode(payload, secret_key, 'RS256')
```
where `private_key` is your private key generated on previous step and `jwt_token` is token required for [session generate jwt api](https://github.com/rubykube/barong/blob/master/docs/index.md#postv1sessionsgeneratejwt).
When params are valid api generates session jwt that you can use for accessing peatio API
