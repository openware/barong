# 2.6 Migration procedure

## Introduction
2.6 version brings some important security improvments by allowing a better isolation of secrets in Vault.
API keys secrets where moved from Vault kv secret engine to transit engine. API keys secrets are encrypted/decrypted by Vault and stored encrypted in the main database, reducing the size of vault storage.

## Setting a unique an meaningful application name
The application name is used as prefix of secrets stored in vault, it allows you to configure proper isolation using vault policies, see [Vault](https://www.openware.com/sdk/docs/barong/vault.html) documentation for more details about ACL configuration.

The configuration entry for the  application name is `barong_vault_app_name` (or the environment variable BARONG_VAULT_APP_NAME), see [Barong Configuration](https://www.openware.com/sdk/docs/barong/configuration.html) for more details.

## Vault token for the migration
To export and import the TOTP you need to use the vault root token or a token with the following policies.
Replace *opendax* with your vault application name.

```
# Read api keys
path "secret/barong/api_key/*" {
  capabilities = ["read"]
}

# Manage the transit secrets engine
path "transit/keys/*" {
  capabilities = [ "create", "read", "list" ]
}

# Encrypt engines secrets
path "transit/encrypt/opendax_apikeys_*" {
  capabilities = [ "create", "read", "update" ]
}

# Decrypt engines secrets
path "transit/decrypt/opendax_apikeys_*" {
  capabilities = [ "create", "read", "update" ]
}

# Export otp
path "totp/export/*" {
  capabilities = ["read"]
}

# Create otp code
path "totp/keys/*" {
  capabilities = ["create", "read", "delete"]
}
```

## Migrate the API keys
This will fetch the API keys from Vault kv secrets store engine, encrypt them with transit, store the encrypted version in the database and finally delete the legacy version stored in vault.

```
rake migrate:26-api-keys
```

## Migrate the TOTP secrets
TOTP secrets can't be exported by the official Vault build.
To do so you must use the openware patched version available in the docker container *quay.io/openware/vault:1.5.3-openware*


Then run the following command

```
rake migrate:26-totp
```
