# API Keys

## How does it work?

To be available to send requiests to the [peatio api](https://github.com/rubykube/peatio/blob/master/docs/api/member_api_v2.md) you need to send proper jwt signed by Barong.
Only Barong knows how to sign valid signature.

### API Key flow:
1. Create an api key with a `public key`, `scopes` and `expired_in`. `Expired_in` is an optional. Default value is 24 hours.
2. Save private key and api key uid to your script
3. Sign request with your private key and provide api key uid as [jwt kid header](https://tools.ietf.org/html/rfc7515#section-4.1.4)
4. Barong read `kid`, select public key and verify your request
5. If payload is valid, Barong generates peatio jwt
6. Use peatio jwt to access to peatio api
7. Peatio jwt token will be expired after `expired_in` time
8. Go to step 3 and repeat next steps again

To create an api key, please use [api key create endpoint](https://github.com/rubykube/barong/blob/master/docs/index.md#postv1apikeys)
To send signed request and generate jwt, please use [generate jwt endpoint](https://github.com/rubykube/barong/blob/master/docs/index.md#postv1sessionsgeneratejwt)

## Configuration

```yml
# JWT configuration.
# You can generate keypair using:
#
#   ruby -e "require 'openssl'; require 'base64'; OpenSSL::PKey::RSA.generate(2048).tap { |p| puts '', 'PRIVATE RSA KEY (URL-safe Base64 encoded, PEM):', '', Base64.urlsafe_encode64(p.to_pem), '', 'PUBLIC RSA KEY (URL-safe Base64 encoded, PEM):', '', Base64.urlsafe_encode64(p.public_key.to_pem) }"
#
```

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

