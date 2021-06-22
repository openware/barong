# Barong environments overview
##### This document provides description, defaults and possible values for all environment variables that take a part in app configuration

### General configuration
| Env name | Default value | Possible values | Description |
| ---------- | ------ |-------------------------|---------------------------------- |
| `barong_app_name` | Barong | any string value | Define app name for `2FA issuer` and `friendly_name` for twilio v2 verification |
| `barong_domain` | openware.com | any string value | Value of the env will be sent as `domain` param in `EVENT API` in identity module, which helps mailer or 3rd party email send services to avoid additional configurations |
| `barong_uid_prefix` | ID | any string value that matches regex: `/^[A-z]{2,6}$/` | This env configurate first 2-6 chars of UID |
| `barong_session_name` | _barong_session |  any string value  | session cookie name |
| `barong_session_expire_time` | 1800 | any number ( value is in seconds) | session lifetime (auto-renews on every private call |
| `barong_required_docs_expire` | true | `false` `true` | force Barong to validate or not validate `expires_in` parameter at document creation. with `false` still can be sent and recorded but with no time validation |
| `barong_doc_num_limit` | 10 | any amount number | number of maximum documents that can be attached to uniq user |
| `barong_geoip_lang` | en | `en`, `de`, `es`, `fr`, `ja`, `ru`  | internal GeoIP lang `Barong::GeoIP.lang`, which configures the language of detected country/continent name |
| `barong_csrf_protection` | true | `true`, `false` | when turned on (`true`) exposes csrf_token on session create and requires X-CSRF-Token on every private POST PUT PATCH DELETE TRACE on AuthZ level |
| `barong_apikey_nonce_lifetime` | 5000 | integer representation of milliseconds | nonce in api key headers should not be older than this env value  |
| `barong_gateway` | 'cloudflare' | `cloudflare`, `akamai` | when turned on (`true`) user IP on session and AuthZ level will firstly be checked in TRUE_CLIENT_IP header |
| `barong_jwt_expire_time` | '3600' | integer representation of seconds  | general purpose tokens (reset password, confirm email) expiration time |
| `crc32_salt` | - | any string value | salt for crc32 algorithm which used to searching in encrypted fields |
| `api_data_masking_enabled` | true | `true`, `false` | when turned on (`true`) user API will be with ecnrypted user data |
|`first_registration_superadmin`| true | `true`, `false` | when turned on (`true`) first registered user on a platform will be superadmin without any email confirmation |
|`mgn_api_keys_user`| false | `true`, `false` | when turned on (`true`) management API to create/update api keys will be provided for user entity|
|`mgn_api_keys_sa`| false | `true`, `false` | when turned on (`true`) management API to create/update api keys will be provided for service account entity |

### Password configuration
| Env name | Default value | Possible values | Description |
| ---------- | ------ |-------------------------|---------------------------------- |
| `barong_password_regexp` | ^(?=.*[[:lower:]])(?=.*[[:upper:]])(?=.*[[:digit:]])(?=.*[[:graph:]]).{8,80}$ | any valid regex without / / | regex will validate password while user sign up / reset pass / password change |
| `barong_password_min_entropy` | 14 | any positive int | minimal entropy required by password |
| `barong_password_use_dictionary` | true | bool | activates or deactivates most common password dictionary check |

### Storage configuration
More details in [storage configuration doc](#storage-configuration)

| Env name | Default value | Possible values | Description |
| ---------- | ------ |-------------------------|---------------------------------- |
| `barong_storage_provider` | local | `local` `google` `aws` `alicloud` | provider for documents store. this env may have an affected on other from this module |
| `barong_storage_bucket_name` | local | any string value | bucket name, required for all providers |
| `barong_storage_access_key` | - | any string value | access key for bucket, required for all providers |
| `barong_storage_secret_key` | - | any string value | secret key for bucket, required for all providers |
| `barong_storage_endpoint` | - | any string valid url value | custom storage endpoint, can be used for AWS, AliCloud providers |
| `barong_storage_signature_version` | 4 |  `2` `3` `4` | custom signature version, can be used for AWS provider |
| `barong_storage_region` | - | any string value | bucket storage region |
| `barong_storage_pathstyle` | false | `false` `true` | storage pathstyle, myght be used for AWS or AliCloud providers |
| `barong_upload_size_min_range` | 1 | any integer value | minimum size of possible upload (in megabytes) |
| `barong_upload_size_max_range` | 10 | any integer value | maximum size of possible upload (in megabytes) |
| `barong_upload_auth_url_expiration` | 1 | any integer value | configures in minutes the lifetime of auth signature to see upload |
| `barong_upload_extension_whitelist` | jpg, jpeg, png, pdf | string with comma-separated extensions formats | whitelist of upload extensions |

### API CORS configuration
| Env name | Default value | Possible values | Description |
| ---------- | ------ |-------------------------|---------------------------------- |
| `barong_api_cors_origins` | * | any string valid url value or wildcard `*` | CORS configuration - url or wildcard |
| `barong_api_cors_max_age` | 3600 | any number ( value is in seconds) | indicates how long the results of a preflight request can be cached, in seconds |
| `barong_api_cors_allow_credentials` | false | `false` `true` | allows cookies to be sent in cross-domain responses |

### CAPTCHA configuration
More details in [captcha policy doc](https://www.openware.com/sdk/docs/barong/general/captcha.html)

| Env name | Default value | Possible values | Description |
| ---------- | ------ |-------------------------|---------------------------------- |
| `barong_captcha` | none | `none` `recaptcha` `geetest` | configures captcha policy |
| `barong_geetest_id` | - | any string value | geetest id for captcha from geetest.com |
| `barong_geetest_key` | - | any string value | geetest id for captcha from geetest.com |
| `barong_recaptcha_site_key` | - | any string value | site key for RECAPTCHA |
| `barong_recaptcha_secret_key` | - | any string value | secret key for RECAPTCHA |

### Twilio configuration
More details in [twilio configuration](#twilio-configuration)

| Env name | Default value | Possible values | Description |
| ---------- | ------ |-------------------------|---------------------------------- |
| `barong_phone_verification` | mock | `twilio_verify` , `twilio_sms` , `mock` | sms send policy, switcher between twilio services and stub (mock) |
| `barong_twilio_phone_number`  | +15005550000 | any twilio valid number or twilio string name | Twilio sms sender number/name |
| `barong_twilio_account_sid` | - | any string value | twilio account sid, required by configuration |
| `barong_twilio_auth_token` | - | any string value | twilio auth token, required by configuration |
| `barong_twilio_service_sid` | - | any string value | twilio service sid, required by configuration of `twilio_verify` policy |
| `barong_sms_content_template` | Your verification code for Barong: `{{code}}` | any string value containing `{{code}}` | template, used in both configurations as content for SMS |

### RabbitMQ configuration
| Env name | Default value | Possible values | Description |
| ---------- | ------ |-------------------------|---------------------------------- |
| `barong_event_api_rabbitmq_host` | localhost | any string value | rabbitmq server host |
| `barong_event_api_rabbitmq_port` | 5672 | any valid port string | rabbitmq server port |
| `barong_event_api_rabbitmq_username` | guest | any string value | rabbitmq server access username |
| `barong_event_api_rabbitmq_password` | guest | any string value | rabbitmq server access password |

### Redis configuration
| `barong_redis_cluster` | `false` | `false` `true` | define redis mode usage (https://redis.io/topics/cluster-tutorial) |
| `barong_redis_url` | `redis://localhost:6379/1` | any valid url | url of redis server with port |
| `barong_redis_password` | ~ | any string value | redis server access password |

### Vault configuration
| `barong_vault_address` | `http://localhost:8200` | any valid url | vault server url with port |
| `barong_vault_token` | | any string value | vault access token |
| `barong_vault_app_name` | barong | any string value | the name of the application, all encryption keys in Vault will be prefixed with this application name |

### Sentry configuration
| `barong_sentry_dsn_backend`  | ~ | valid host url | Sentry SDK client key |

### Auth0 configuration

| Env name | Default value | Possible values | Description |
| ---------- | :------: |:------: |---------------------------------- |
|`auth0_domain`| - | any string value | auth0 Domain name (without https://) |
|`auth0_client_id`| - | any string value | the client_id of your auth0 application |

### SMTP configuration
| Env name | Default value | Possible values | Description |
| ---------- | ------ |-------------------------|---------------------------------- |
| `barong_sender_email`  | noreply@barong.io | any valid email | this will be displayed as sender email for client in all outbox |
| `barong_sender_name` | Barong | any string value | this will be displayed as sender name for client in all outbox |
| `barong_smtp_password` | - | any string value | password for auth 3d party send emails service smtp |
| `barong_smtp_port`  | 1025 | any integer value | port for auth 3d party send emails service smtp |
| `barong_smtp_host`  | localhost | valid host url | host for auth 3d party send emails service smtp |
| `barong_smtp_user`  | - | any string value | username for auth 3d party send emails service smtp |
| `barong_default_language`  | en | alpha-2 country | default language for email letters |

### Config files configuration
| Env name | Default value | Possible values | Description |
| ---------- | ------ |-------------------------|---------------------------------- |
| `barong_config`  | config/barong.yml | any valid path to existing file | path to barong config with `activation_requirements`, `state_triggers`, `document_types` and `user_storage_titles` |
| `barong_maxminddb_path` | geolite/GeoLite2-Country.mmdb | any valid path to existing file | path to geolite country DB file |
| `barong_seeds_file` | config/seeds.yml | any valid path to existing file | path to configuration file with pre-defined API rules, users and levels | 
| `barong_authz_rules_file` | config/authz_rules.yml | any valid path to existing file | path to configuration file with blacklisted and whitelisted API pathes |

# Barong configurations overview
## Twilio configuration
For twilio configuration we need to set such required envs
- `BARONG_TWILIO_ACCOUNT_SID`, which acts as a twilio username
- `BARONG_TWILIO_SERVICE_SID`, which acts as a twilio password
- `BARONG_TWILIO_PHONE_NUMBER`, virtual phone numbers which will give you instant access to local, national, mobile, and toll-free phone numbers

We have ability to set twilio with 3 different ways
1. ```BARONG_PHONE_VERIFICATION == "twilio_sms"```
     If you choose phone verification as twilio sms we will use send_sms [API call](https://www.twilio.com/docs/sms/send-messages)
       Also you can add your own template for sms using `BARONG_SMS_CONTENT_TEMPLATE`
2. ```BARONG_PHONE_VERIFICATION == "twilio_verify"```
     In this case we will use twilio Verify [API call](https://www.twilio.com/docs/verify/api)
     There are a lot of benefits of using Verify API like you can validate users via voice
     One verification service can be used to send multiple verification tokens, it is not necessary to create a new service each time, so you can set ```BARONG_TWILIO_SERVICE_SID``` at once
3. ```BARONG_PHONE_VERIFICATION == "mock"```
     With this type of verification all the numbers will be accepted and validated as a right code for any given number

---

## Blacklist/Whitelist configuration

`Pass` routes will never be checked by AuthZ endpoint and will be available without session requirement. On `Block` routes user always will get 401, it doesn't depend on a session / role / ip / etc

You need to put whitelisted (public) routes for pass object and blacklisted routes for block in authz_rules.yml

```yml
rules:
  pass:
  	- api/v2/barong/identity
  	- api/v2/peatio/public
  	- api/v2/ranger/public
  	- api/v2/applogic/public
   block:
  	- api/v2/barong/management
  	- api/v2/peatio/managemen
```

---

## State configuration

We can customize barong configuration as we want

1. For user activation we just need to have verified email label in example below. You can put  more labels to create your own rules for user activation
2. For example, if you want to ban your user you just need to put ban and fraud labels on tower admin panel. For sure you can customize this case too and put change or add label names in barong.yml
3. For document verification we use, as standard - following document types. But you can configure available document types by changing or extending existing list. This way we keep an opportunity to support any custom KYC services, logic, etc

```yml
activation_requirements:
  email: 'verified'
state_triggers:
  banned:
    - ban
    - fraud
  deleted:
    - delete
  locked:
    - suspicious
    - lock
document_types:
  - Passport
  - Identity card
  - Driver license
  - Utility Bill
  - Residental
  - Institutional
```
