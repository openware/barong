# Vault configuration

## Introduction

This document describes how to create vault tokens in order to restrict components access to vault as following

| Component    | Abilities                                               |
| ------------ | ------------------------------------------------------- |
| barong-rails | encrypt api keys<br />create TOTP<br />verify TOTP code |
| barong-authz | decrypt api keys                                        |



## Connect to vault
The the following variables in your environment with correct values:

```bash
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='s.ozytsgX1BcTQaR5Y07SAd2VE'
```

You can test that it works running the following command:

```
$ vault status
Type: shamir
Sealed: false
Key Shares: 1
Key Threshold: 1
Unseal Progress: 0
Unseal Nonce: 
Version: 1.3.4
Cluster Name: vault-cluster-650930cf
Cluster ID: 9f40327d-ec71-9655-b728-7588ce47d0b4

High-Availability Enabled: false
```

## Create ACL groups

### Create the following policy files

**barong-rails.hcl**

Replace *opendax* with your vault application name. See [barong vault configuration](https://www.openware.com/sdk/docs/barong/configuration.html#vault-configuration) for more details.

```bash
# Access system health status
path "sys/health" {
  capabilities = ["read", "list"]
}

# Manage the transit secrets engine
path "transit/keys/*" {
  capabilities = [ "create", "read", "list" ]
}

# Encrypt engines secrets
path "transit/encrypt/opendax_apikeys_*" {
  capabilities = [ "create", "read", "update" ]
}

# Renew tokens
path "auth/token/renew" {
  capabilities = [ "update" ]
}

# Lookup tokens
path "auth/token/lookup" {
  capabilities = [ "update" ]
}

# Manage otp keys
path "totp/keys/opendax_*" {
  capabilities = ["create", "read", "update", "delete"]
}

# Verify an otp code
path "totp/code/opendax_*" {
  capabilities = ["update"]
}
```

**barong-authz.hcl**

```bash
# Access system health status
path "sys/health" {
  capabilities = ["read", "list"]
}

# Manage the transit secrets engine
path "transit/keys/*" {
  capabilities = [ "create", "read", "list" ]
}

# Decrypt engines secrets
path "transit/decrypt/opendax_apikeys_*" {
  capabilities = [ "create", "read", "update" ]
}

# Renew tokens
path "auth/token/renew" {
  capabilities = [ "update" ]
}

# Lookup tokens
path "auth/token/lookup" {
  capabilities = [ "update" ]
}
```

### Create the ACL groups in vault

```bash
vault policy write barong-rails barong-rails.hcl
vault policy write barong-authz barong-authz.hcl
```

### Create applications tokens

```bash
vault token create -policy=barong-rails -period=240h
vault token create -policy=barong-authz -period=240h
```

## Configure Barong

Set those variables according to your deployment:

```bash
export BARONG_VAULT_ADDRESS=http://127.0.0.1:8200
export BARONG_VAULT_TOKEN=s.jyH1vmrOmkZ0FZZ0NZtgRenS
export BARONG_VAULT_APP_NAME=opendax
```
