# Setting up 2FA

This document describes Barong [TOTP](https://tools.ietf.org/html/rfc6238) setup
using [Vault](https://www.vaultproject.io/intro/getting-started/install.html).

## Prerequisites

[Vault](https://www.vaultproject.io/intro/getting-started/install.html)
with [TOTP secrets engine](https://www.vaultproject.io/docs/secrets/totp/index.html#setup) enabled.

## Configuration

To use Vault with Barong you will need to set the following environment variables:

```shell
export VAULT_ADDR=http://your-vault-url.com
export VAULT_TOKEN=12345-vault-t0k3n-54321
```

To allow using Google Authenticator `VAULT_ADDR` should be _public_ ip.

Note, that TOTP uses time-based algorithm.
So, if you want to test 2FA with phone, make sure, that your Vault's server time and your phone's time are synchronized, or it will not work.
[ntpdate](http://doc.ntp.org/4.1.1/ntpdate.htm) can help you to update your time with ntp servers:

```shell
sudo ntpdate 0.ua.pool.ntp.org
```


## Developer How-tos

### Getting a code without Google Authenticator:

* From _shell_:

    ```shell
    $ vault login
    $ vault read totp/code/IDMYAWESOMEID
    ```

* From _rails console_:

    ```ruby
    > me = Account.find_by_email('me@example.com')
    > Vault.logical.read("totp/code/#{me.uid}")
    ```

### Getting a new key (e.g. if you lost your Google Authenticator):

* From _shell_:

    ```shell
    $ vault login
    $ vault write totp/keys/IDMYAWESOMEID \
        generate=true                     \
        issuer=Barong                     \
        account_name=me@example.com
    ```

* From _rails console_:

    ```ruby
    > me = Account.find_by_email('me@example.com')
    > Vault::TOTP.send(:create, me.uid)
    ```

Each response includes equivalent base64-encoded barcode and OTP url.
You can find the key's secret in this OTP url query params.

