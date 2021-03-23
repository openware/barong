# Barong
RESTful API for barong OAuth server

## Version: 2.7.0

### /api/v2/barong/identity/users/password/confirm_code

#### POST
##### Description

Sets new account password

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| reset_password_token | formData | Token from email | Yes | string |
| password | formData | User password | Yes | string |
| confirm_password | formData | User password | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Resets password |
| 400 | Required params are empty |
| 404 | Record is not found |
| 422 | Validation errors |

### /api/v2/barong/identity/users/password/generate_code

#### POST
##### Description

Send password reset instructions

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| email | formData | Account email | Yes | string |
| captcha_response | formData | Response from captcha widget | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Generated password reset code |
| 400 | Required params are missing |
| 404 | User doesn't exist |
| 422 | Validation errors |

### /api/v2/barong/identity/users/email/confirm_code

#### POST
##### Description

Confirms an account

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| token | formData | Token from email | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Confirms an account | [API_V2_Entities_UserWithFullInfo](#api_v2_entities_userwithfullinfo) |
| 400 | Required params are missing |  |
| 422 | Validation errors |  |

### /api/v2/barong/identity/users/email/generate_code

#### POST
##### Description

Send confirmations instructions

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| email | formData | Account email | Yes | string |
| captcha_response | formData | Response from captcha widget | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Generated verification code |
| 400 | Required params are missing |
| 422 | Validation errors |

### /api/v2/barong/identity/users/register_geetest

#### GET
##### Description

Register Geetest captcha

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Register Geetest captcha |

### /api/v2/barong/identity/users

#### POST
##### Description

Creates new user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| email | formData | User Email | Yes | string |
| password | formData | User Password | Yes | string |
| username | formData | User Username | No | string |
| refid | formData | Referral uid | No | string |
| captcha_response | formData | Response from captcha widget | No | string |
| data | formData | Any additional key: value pairs in json string format | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Creates new user | [API_V2_Entities_UserWithFullInfo](#api_v2_entities_userwithfullinfo) |
| 400 | Required params are missing |  |
| 422 | Validation errors |  |

### /api/v2/barong/identity/users/access

#### POST
##### Description

Creates new whitelist restriction

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| whitelink_token | formData |  | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Whitelist restriction was created |
| 400 | Required params are missing |
| 422 | Validation errors |

### /api/v2/barong/identity/sessions

#### DELETE
##### Description

Destroy current session

##### Responses

| Code | Description |
| ---- | ----------- |
| 204 | Session was destroyed |
| 400 | Required params are empty |
| 404 | Record is not found |

#### POST
##### Description

Start a new session

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| email | formData |  | Yes | string |
| password | formData |  | Yes | string |
| captcha_response | formData | Response from captcha widget | No | string |
| otp_code | formData | Code from Google Authenticator | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Start a new session | [API_V2_Entities_UserWithFullInfo](#api_v2_entities_userwithfullinfo) |
| 400 | Required params are empty |  |
| 404 | Record is not found |  |

### /api/v2/barong/identity/configs

#### GET
##### Description

Get barong configurations

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get barong configurations |

### /api/v2/barong/identity/version

#### GET
##### Description

Get barong version

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get barong version |

### /api/v2/barong/identity/time

#### GET
##### Description

Get server current unix timestamp.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get server current unix timestamp. |

### /api/v2/barong/identity/ping

#### GET
##### Description

Test connectivity

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Test connectivity |

### /api/v2/barong/identity/password/validate

#### POST
##### Description

Password strength testing

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| password | formData | User password | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Password strength testing |

### /api/v2/barong/resource/swagger_doc/{name}

#### GET
##### Description

Swagger compatible API description for specific API

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| name | path | Resource name of mounted API | Yes | string |
| locale | query | Locale of API documentation | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Swagger compatible API description for specific API |

### /api/v2/barong/resource/swagger_doc

#### GET
##### Description

Swagger compatible API description

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Swagger compatible API description |

### /api/v2/barong/resource/service_accounts/api_keys/{kid}

#### PUT
##### Description

Updates an api key

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| service_account_uid | formData |  | Yes | string |
| kid | path | Service account kid | Yes | string |
| scope | formData | Comma separated scopes | No | string |
| state | formData | State of API Key. "active" state means key is active and can be used for auth | No | string |
| totp_code | formData | Code from Google Authenticator | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Updates an api key | [API_V2_Entities_APIKey](#api_v2_entities_apikey) |
| 400 | Required params are empty |  |
| 401 | Invalid bearer token |  |
| 404 | Record is not found |  |
| 422 | Validation errors |  |

#### DELETE
##### Description

Delete an api key for specific service account

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| service_account_uid | query |  | Yes | string |
| kid | path | Service account kid | Yes | string |
| totp_code | query | Code from Google Authenticator | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 204 | Succefully deleted |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Record is not found |

### /api/v2/barong/resource/service_accounts/api_keys

#### POST
##### Description

Create api key for specific service account.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| service_account_uid | formData |  | Yes | string |
| algorithm | formData | Service account algorithm | Yes | string |
| scope | formData | Comma separated scopes | No | string |
| totp_code | formData | Code from Google Authenticator | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create api key for specific service account. | [API_V2_Entities_APIKey](#api_v2_entities_apikey) |
| 400 | Require 2FA and totp code |  |
| 401 | Invalid bearer token |  |

#### GET
##### Description

List all api keys for specific service account.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |
| service_account_uid | query |  | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | List all api keys for specific service account. | [API_V2_Entities_APIKey](#api_v2_entities_apikey) |
| 400 | Require 2FA and totp code |  |
| 401 | Invalid bearer token |  |

### /api/v2/barong/resource/service_accounts

#### GET
##### Description

List all service accounts for current user.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | List all service accounts for current user. |
| 400 | Require 2FA and totp code |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /api/v2/barong/resource/data_storage

#### POST
##### Description

Create data storage

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| title | formData | Storage title | Yes | string |
| data | formData | Storage data | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Data Storage was created |
| 401 | Invalid bearer token |
| 422 | Validation errors |

### /api/v2/barong/resource/api_keys

#### GET
##### Description

List all api keys for current account.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | List all api keys for current account. | [API_V2_Entities_APIKey](#api_v2_entities_apikey) |
| 400 | Require 2FA and totp code |  |
| 401 | Invalid bearer token |  |

#### POST
##### Description

Create an api key

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| algorithm | formData | API key algorithm | Yes | string |
| scope | formData | Comma separated scopes | No | string |
| totp_code | formData | Code from Google Authenticator | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create an api key | [API_V2_Entities_APIKey](#api_v2_entities_apikey) |
| 400 | Required params are empty |  |
| 401 | Invalid bearer token |  |
| 422 | Validation errors |  |

### /api/v2/barong/resource/api_keys/{kid}

#### DELETE
##### Description

Delete an api key

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| kid | path | API key kid | Yes | string |
| totp_code | query | Code from Google Authenticator | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 204 | Succefully deleted |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Record is not found |

#### PATCH
##### Description

Updates an api key

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| kid | path | API key kid | Yes | string |
| scope | formData | Comma separated scopes | No | string |
| state | formData | State of API Key. "active" state means key is active and can be used for auth | No | string |
| totp_code | formData | Code from Google Authenticator | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Updates an api key | [API_V2_Entities_APIKey](#api_v2_entities_apikey) |
| 400 | Required params are empty |  |
| 401 | Invalid bearer token |  |
| 404 | Record is not found |  |
| 422 | Validation errors |  |

### /api/v2/barong/resource/otp/verify

#### POST
##### Description

Verify 2FA code

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| code | formData | Code from Google Authenticator | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | 2FA was verified |
| 400 | 2FA has not been enabled for this account or code is missing |
| 401 | Invalid bearer token |
| 422 | Validation errors |

### /api/v2/barong/resource/otp/disable

#### POST
##### Description

Disable 2FA

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| code | formData | Code from Google Authenticator | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | 2FA was disabled |
| 400 | 2FA has not been enabled for this account or code is missing |
| 401 | Invalid bearer token |
| 422 | Validation errors |

### /api/v2/barong/resource/otp/enable

#### POST
##### Description

Enable 2FA

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| code | formData | Code from Google Authenticator | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | 2FA was enabled |
| 400 | 2FA has been enabled for this account or code is missing |
| 401 | Invalid bearer token |
| 422 | Validation errors |

### /api/v2/barong/resource/otp/generate_qrcode

#### POST
##### Description

Generate qr code for 2FA

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | QR code was generated |
| 400 | 2FA has been enabled for this account |
| 401 | Invalid bearer token |

### /api/v2/barong/resource/phones/verify

#### POST
##### Description

Verify a phone

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| phone_number | formData | Phone number with country code | Yes | string |
| verification_code | formData | Verification code from sms | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Verify a phone | [API_V2_Entities_UserWithFullInfo](#api_v2_entities_userwithfullinfo) |
| 400 | Required params are empty |  |
| 401 | Invalid bearer token |  |
| 404 | Record is not found |  |

### /api/v2/barong/resource/phones/send_code

#### POST
##### Description

Resend activation code

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| phone_number | formData | Phone number with country code | Yes | string |
| channel | formData | The verification method to use | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Activation code was resend |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Record is not found |
| 422 | Validation errors |

### /api/v2/barong/resource/phones

#### POST
##### Description

Add new phone

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| phone_number | formData | Phone number with country code | Yes | string |
| channel | formData | The verification method to use | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | New phone was added |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Record is not found |
| 422 | Validation errors |

#### GET
##### Description

Returns list of user's phones

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns list of user's phones | [API_V2_Entities_Phone](#api_v2_entities_phone) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/resource/documents

#### POST
##### Description

Upload a new document for current user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| doc_type | formData | Document type | Yes | string |
| doc_number | formData | Document number | Yes | string |
| upload | formData | Array of Rack::Multipart::UploadedFile | Yes | string |
| doc_expire | formData | Document expiration date | No | date |
| doc_category | formData | Category of the submitted document - front/back/selfie etc. | No | string |
| identificator | formData | Identificator for documents to be supplied together | No | string |
| metadata | formData | Any additional key: value pairs in json string format | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Document is uploaded |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 422 | Validation errors |

#### GET
##### Description

Return current user documents list

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Return current user documents list | [API_V2_Entities_Document](#api_v2_entities_document) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/resource/profiles

#### PUT
##### Description

Update a profile for current_user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| first_name | formData | First Name | No | string |
| last_name | formData | Last Name | No | string |
| dob | formData | Date of Birth | No | date |
| address | formData | Address | No | string |
| postcode | formData | Postcode | No | string |
| city | formData | City | No | string |
| country | formData | Country | No | string |
| metadata | formData | Any additional key: value pairs in json string format | No | string |
| confirm | formData | Profile confirmation | No | boolean |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Update a profile for current_user | [API_V2_Entities_Profile](#api_v2_entities_profile) |
| 401 | Invalid bearer token |  |
| 422 | Validation errors |  |

#### POST
##### Description

Create a profile for current_user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| first_name | formData | First Name | No | string |
| last_name | formData | Last Name | No | string |
| dob | formData | Date of Birth | No | date |
| address | formData | Address | No | string |
| postcode | formData | Postcode | No | string |
| city | formData | City | No | string |
| country | formData | Country | No | string |
| metadata | formData | Any additional key: value pairs in json string format | No | string |
| confirm | formData | Profile confirmation | No | boolean |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create a profile for current_user | [API_V2_Entities_Profile](#api_v2_entities_profile) |
| 400 | Required params are empty |  |
| 401 | Invalid bearer token |  |
| 409 | Profile already exists |  |
| 422 | Validation errors |  |

### /api/v2/barong/resource/profiles/me

#### GET
##### Description

Return profiles of current resource owner

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Return profiles of current resource owner | [API_V2_Entities_Profile](#api_v2_entities_profile) |
| 401 | Invalid bearer token |  |
| 404 | User has no profile |  |

### /api/v2/barong/resource/labels/{key}

#### DELETE
##### Description

Delete a label  with 'public' scope.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| key | path | Label key. | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 204 | Succefully deleted |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Record is not found |

#### PATCH
##### Description

Update a label with 'public' scope.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| key | path | Label key. | Yes | string |
| value | formData | Label value. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Update a label with 'public' scope. | [API_V2_Entities_Label](#api_v2_entities_label) |
| 400 | Required params are empty |  |
| 401 | Invalid bearer token |  |
| 404 | Record is not found |  |
| 422 | Validation errors |  |

#### GET
##### Description

Return a label by key.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| key | path | Label key. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Return a label by key. | [API_V2_Entities_Label](#api_v2_entities_label) |
| 400 | Required params are empty |  |
| 401 | Invalid bearer token |  |
| 404 | Record is not found |  |

### /api/v2/barong/resource/labels

#### POST
##### Description

Create a label with 'public' scope.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| key | formData | Label key. | Yes | string |
| value | formData | Label value. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create a label with 'public' scope. | [API_V2_Entities_Label](#api_v2_entities_label) |
| 400 | Required params are empty |  |
| 401 | Invalid bearer token |  |
| 422 | Validation errors |  |

#### GET
##### Description

List all labels for current user.

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | List all labels for current user. | [API_V2_Entities_Label](#api_v2_entities_label) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/resource/users/password

#### PUT
##### Description

Sets new account password

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| old_password | formData | Previous account password | Yes | string |
| new_password | formData | User password | Yes | string |
| confirm_password | formData | User password | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Changes password |
| 400 | Required params are empty |
| 404 | Record is not found |
| 422 | Validation errors |

### /api/v2/barong/resource/users/activity/{topic}

#### GET
##### Description

Returns user activity

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| topic | path | Topic of user activity. Allowed: [all, password, session, otp] | Yes | string |
| time_from | query | An integer represents the seconds elapsed since Unix epoch.If set, only activities created after the time will be returned. | No | integer |
| time_to | query | An integer represents the seconds elapsed since Unix epoch.If set, only activities created before the time will be returned. | No | integer |
| result | query | Result of user activity. Allowed: [succeed, failed, denied] | No | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns user activity | [API_V2_Entities_Activity](#api_v2_entities_activity) |

### /api/v2/barong/resource/users/me

#### DELETE
##### Description

Blocks current user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| password | query | Account password | Yes | string |
| otp_code | query | Code from Google Authenticator | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 204 | Current user was blocked |

#### PUT
##### Description

Updates current user data field

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| data | formData | Any additional key: value pairs in json string format | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Updates current user data field | [API_V2_Entities_UserWithFullInfo](#api_v2_entities_userwithfullinfo) |

#### GET
##### Description

Returns current user

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns current user | [API_V2_Entities_UserWithFullInfo](#api_v2_entities_userwithfullinfo) |

### /api/v2/barong/resource/addresses

#### POST
##### Description

Upload a new address approval document for current user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| country | formData | Document type | Yes | string |
| address | formData | Document number | Yes | string |
| upload | formData | Array of Rack::Multipart::UploadedFile | Yes | string |
| city | formData | Document expiration date | Yes | string |
| postcode | formData | Any additional key: value pairs in json string format | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | New address approval document was uploaded |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 422 | Validation errors |

### /api/v2/barong/public/configs

#### GET
##### Description

Get barong configurations

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get barong configurations |

### /api/v2/barong/public/version

#### GET
##### Description

Get barong version

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get barong version |

### /api/v2/barong/public/time

#### GET
##### Description

Get server current unix timestamp.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get server current unix timestamp. |

### /api/v2/barong/public/ping

#### GET
##### Description

Test connectivity

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Test connectivity |

### /api/v2/barong/public/password/validate

#### POST
##### Description

Password strength testing

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| password | formData | User password | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Password strength testing |

### /api/v2/barong/public/kyc

#### POST
##### Description

KYC callback

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | KYC callback |

### Models

#### API_V2_Entities_UserWithFullInfo

Returns current user

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| email | string | User Email | No |
| uid | string | User UID | No |
| role | string | User role | No |
| level | integer | User level | No |
| otp | boolean | is 2FA enabled for account | No |
| state | string | User state: active, pending, inactive | No |
| referral_uid | string | UID of referrer | No |
| data | string | Additional phone and profile info | No |
| csrf_token | string | Сsrf protection token | No |
| labels | [API_V2_Entities_Label](#api_v2_entities_label) |  | No |
| phones | [API_V2_Entities_Phone](#api_v2_entities_phone) |  | No |
| profiles | [API_V2_Entities_Profile](#api_v2_entities_profile) |  | No |
| data_storages | [API_V2_Entities_DataStorage](#api_v2_entities_datastorage) |  | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_Label

List all labels for current user.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| key | string | Label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters. | No |
| value | string | Label value. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters. | No |
| scope | string | Label scope: 'public' or 'private' | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_Phone

Returns list of user's phones

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| country | string | Phone country | No |
| number | string | Submasked phone number | No |
| validated_at | s (g) | Phone validation date | No |

#### API_V2_Entities_Profile

Return profiles of current resource owner

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| first_name | string | First Name | No |
| last_name | string | Submasked last name | No |
| dob | date | Submasked birth date | No |
| address | string | Address | No |
| postcode | string | Address Postcode | No |
| city | string | City name | No |
| country | string | Country name | No |
| state | string | Profile state: drafted, submitted, verified, rejected | No |
| metadata | object | Profile additional fields | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_DataStorage

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| title | string | Any additional data title | No |
| data | string | Any additional data json key:value pairs | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_APIKey

Create an api key

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| kid | string | JWT public key | No |
| algorithm | string | Cryptographic hash function type | No |
| scope | string | Serialized array of scopes | No |
| state | string | active/non-active state of key | No |
| secret | string | Api key secret | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_Document

Return current user documents list

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| upload | string | File url | No |
| doc_type | string | Document type: passport, driver license, utility bill, identity card, institutional, address, residental | No |
| doc_number | string | Submasked document number: AB123123 type | No |
| doc_expire | string | Expire date of uploaded documents | No |
| metadata | string | Any additional stored data | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_Activity

Returns user activity

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Activity ID | No |
| user_ip | string | User IP | No |
| user_agent | string | User Browser Agent | No |
| topic | string | Defined topic (session, adjustments) or general by default | No |
| action | string | API action: POST => 'create', PUT => 'update', GET => 'read', DELETE => 'delete', PATCH => 'update' or system if there is no match of HTTP method | No |
| result | string | Status of API response: succeed, failed, denied | No |
| data | string | Parameters which was sent to specific API endpoint | No |
| created_at | string |  | No |

#### API_V2_Entities_Level

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Level identifier, level number | No |
| key | string | Label key. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters. | No |
| value | string | Label value. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters. | No |

#### API_V2_Entities_User

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| email | string | User Email | No |
| uid | string | User UID | No |
| role | string | User role | No |
| level | integer | User level | No |
| otp | boolean | is 2FA enabled for account | No |
| state | string | User state: active, pending, inactive | No |
| referral_uid | string | UID of referrer | No |
| data | string | Additional phone and profile info | No |

#### API_V2_Entities_UserWithProfile

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| email | string | User Email | No |
| uid | string | User UID | No |
| role | string | User role | No |
| level | integer | User level | No |
| otp | boolean | is 2FA enabled for account | No |
| state | string | User state: active, pending, inactive | No |
| referral_uid | string | UID of referrer | No |
| data | string | Additional phone and profile info | No |
| profiles | [API_V2_Entities_Profile](#api_v2_entities_profile) |  | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_UserWithKYC

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| email | string | User Email | No |
| uid | string | User UID | No |
| role | string | User role | No |
| level | integer | User level | No |
| otp | boolean | is 2FA enabled for account | No |
| state | string | User state: active, pending, inactive | No |
| referral_uid | string | UID of referrer | No |
| data | string | Additional phone and profile info | No |
| profiles | [API_V2_Entities_Profile](#api_v2_entities_profile) |  | No |
| labels | [API_V2_Entities_AdminLabelView](#api_v2_entities_adminlabelview) |  | No |
| phones | [API_V2_Entities_Phone](#api_v2_entities_phone) |  | No |
| documents | [API_V2_Entities_Document](#api_v2_entities_document) |  | No |
| data_storages | [API_V2_Entities_DataStorage](#api_v2_entities_datastorage) |  | No |
| comments | [API_V2_Entities_Comment](#api_v2_entities_comment) |  | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_AdminLabelView

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| key | string | Label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters. | No |
| value | string | Label value. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters. | No |
| scope | string | Label scope: 'public' or 'private' | No |
| description | string | Label desc: json string with any additional information | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_Comment

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Comment id | No |
| author_uid | string | Comment author UID | No |
| title | string | Comment title | No |
| data | string | Comment plain text | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_ServiceAccounts

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| email | string | User Email | No |
| uid | string | User UID | No |
| role | string | Service Account Role | No |
| level | integer | User Level | No |
| state | string | Service Account State: active, disabled | No |
| user | [API_V2_Entities_User](#api_v2_entities_user) |  | No |
| created_at | string |  | No |
| updated_at | string |  | No |
