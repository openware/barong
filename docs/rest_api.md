# Barong
RESTful API for barong OAuth server

## Version: 2.0.30-alpha

### Security
**BearerToken**  

|jwt|*undefined*|
|---|---|
|Description|Bearer Token authentication|
|Name|Authorization|
|In|header|

### /admin/metrics

#### GET
##### Description:

Returns main statistic in the given time period

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| created_from | query |  | No | string |
| created_to | query |  | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Returns main statistic in the given time period |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /admin/activities/admin

#### GET
##### Description:

Returns array of activities as paginated collection

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| topic | query |  | No | string |
| action | query |  | No | string |
| uid | query |  | No | string |
| email | query |  | No | string |
| target_uid | query |  | No | string |
| range | query |  | No | string |
| from | query |  | No | string |
| to | query |  | No | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Returns array of activities as paginated collection |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /admin/activities

#### GET
##### Description:

Returns array of activities as paginated collection

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| topic | query |  | No | string |
| action | query |  | No | string |
| uid | query |  | No | string |
| email | query |  | No | string |
| from | query |  | No | string |
| to | query |  | No | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Returns array of activities as paginated collection |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /admin/permissions

#### PUT
##### Description:

Update Permission

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | formData | Permission id | Yes | string |
| role | formData | permission field - role | No | string |
| req_type | formData | permission field - request type | No | boolean |
| path | formData | permission field - request path | No | string |
| action | formData |  | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Update Permission |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

#### DELETE
##### Description:

Deletes permission

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | query | permission id | Yes | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 204 | Deletes permission |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

#### POST
##### Description:

Create permission

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| role | formData |  | Yes | string |
| verb | formData |  | Yes | string |
| path | formData |  | Yes | string |
| action | formData |  | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Create permission |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

#### GET
##### Description:

Returns array of permissions as paginated collection

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Returns array of permissions as paginated collection |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /admin/users/{uid}

#### GET
##### Description:

Returns user info

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | path | user uniq id | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Returns user info |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /admin/users/labels

#### DELETE
##### Description:

Deletes label for user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | query | user uniq id | Yes | string |
| key | query | label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters. | Yes | string |
| scope | query | label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters. | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 204 | Deletes label for user |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

#### PUT
##### Description:

Update user label scope

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | user uniq id | Yes | string |
| key | formData | Label key. | Yes | string |
| scope | formData | label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters. | Yes | string |
| value | formData | Label value. | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Update user label scope |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Record is not found |
| 422 | Validation errors |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

#### POST
##### Description:

Adds label for user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | user uniq id | Yes | string |
| key | formData | label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters. | Yes | string |
| value | formData | label value. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters. | Yes | string |
| scope | formData | Label scope: 'public' or 'private'. Default is public | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Adds label for user |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

#### GET
##### Description:

Returns array of users as paginated collection

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| key | query | Label key | Yes | string |
| value | query | Label value | Yes | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 1000). | No | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Returns array of users as paginated collection |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /admin/users/labels/update

#### POST
##### Description:

Update user label scope

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | user uniq id | Yes | string |
| key | formData | Label key. | Yes | string |
| scope | formData | label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters. | Yes | string |
| value | formData | Label value. | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Update user label scope |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Record is not found |
| 422 | Validation errors |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /admin/users/labels/list

#### GET
##### Description:

Returns existing labels keys and values

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Returns existing labels keys and values |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /admin/users/documents/pending

#### GET
##### Description:

Returns array of users with pending documents as paginated collection

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| extended | query | When true endpoint returns full information about users | No | boolean |
| uid | query |  | No | string |
| email | query |  | No | string |
| role | query |  | No | string |
| first_name | query |  | No | string |
| last_name | query |  | No | string |
| country | query |  | No | string |
| level | query |  | No | integer |
| state | query |  | No | string |
| range | query |  | No | string |
| from | query |  | No | string |
| to | query |  | No | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 1000). | No | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Returns array of users with pending documents as paginated collection |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /admin/users

#### PUT
##### Description:

Update user attributes

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | user uniq id | Yes | string |
| state | formData | user state | No | string |
| otp | formData | user 2fa status | No | boolean |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Update user attributes |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

#### GET
##### Description:

Returns array of users as paginated collection

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| extended | query | When true endpoint returns full information about users | No | boolean |
| uid | query |  | No | string |
| email | query |  | No | string |
| role | query |  | No | string |
| first_name | query |  | No | string |
| last_name | query |  | No | string |
| country | query |  | No | string |
| level | query |  | No | integer |
| state | query |  | No | string |
| range | query |  | No | string |
| from | query |  | No | string |
| to | query |  | No | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Returns array of users as paginated collection |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /admin/users/role

#### POST
##### Description:

Update user role

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | user uniq id | Yes | string |
| role | formData | user role | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Update user role |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /admin/users/update

#### POST
##### Description:

Update user attributes

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | user uniq id | Yes | string |
| state | formData | user state | No | string |
| otp | formData | user 2fa status | No | boolean |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Update user attributes |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /identity/users/password/confirm_code

#### POST
##### Description:

Sets new account password

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| reset_password_token | formData | Token from email | Yes | string |
| password | formData | User password | Yes | string |
| confirm_password | formData | User password | Yes | string |
| lang | formData | Language in iso-2 format | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Resets password |
| 400 | Required params are empty |
| 404 | Record is not found |
| 422 | Validation errors |

### /identity/users/password/generate_code

#### POST
##### Description:

Send password reset instructions

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| email | formData | Account email | Yes | string |
| lang | formData | Language in iso-2 format | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Generated password reset code |
| 400 | Required params are missing |
| 404 | User doesn't exist |
| 422 | Validation errors |

### /identity/users/email/confirm_code

#### POST
##### Description:

Confirms an account

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| token | formData | Token from email | Yes | string |
| lang | formData | Language in iso-2 format | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Confirms an account |
| 400 | Required params are missing |
| 422 | Validation errors |

### /identity/users/email/generate_code

#### POST
##### Description:

Send confirmations instructions

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| email | formData | Account email | Yes | string |
| lang | formData | Client env language | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Generated verification code |
| 400 | Required params are missing |
| 422 | Validation errors |

### /identity/users/register_geetest

#### GET
##### Description:

Register Geetest captcha

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Register Geetest captcha |

### /identity/users

#### POST
##### Description:

Creates new user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| email | formData | User Email | Yes | string |
| password | formData | User Password | Yes | string |
| refid | formData | Referral uid | No | string |
| lang | formData | Client env language | No | string |
| captcha_response | formData | Response from captcha widget | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Creates new user |
| 400 | Required params are missing |
| 422 | Validation errors |

### /identity/sessions

#### DELETE
##### Description:

Destroy current session

##### Responses

| Code | Description |
| ---- | ----------- |
| 204 | Destroy current session |
| 400 | Required params are empty |
| 404 | Record is not found |

#### POST
##### Description:

Start a new session

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| email | formData |  | Yes | string |
| password | formData |  | Yes | string |
| captcha_response | formData | Response from captcha widget | No | string |
| otp_code | formData | Code from Google Authenticator | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Start a new session |
| 400 | Required params are empty |
| 404 | Record is not found |

### /identity/version

#### GET
##### Description:

Get barong version

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get barong version |

### /identity/time

#### GET
##### Description:

Get server current unix timestamp.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get server current unix timestamp. |

### /identity/ping

#### GET
##### Description:

Test connectivity

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Test connectivity |

### /resource/api_keys

#### GET
##### Description:

List all api keys for current account.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of api keys per page (defaults to 100, maximum is 1000). | No | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | List all api keys for current account. |
| 400 | Require 2FA and totp code |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

#### POST
##### Description:

Create an api key

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| algorithm | formData |  | Yes | string |
| kid | formData |  | No | string |
| scope | formData | comma separated scopes | No | string |
| totp_code | formData | Code from Google Authenticator | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Create an api key |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 422 | Validation errors |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /resource/api_keys/{kid}

#### DELETE
##### Description:

Delete an api key

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| kid | path |  | Yes | string |
| totp_code | query | Code from Google Authenticator | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 204 | Succefully deleted |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Record is not found |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

#### PATCH
##### Description:

Updates an api key

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| kid | path |  | Yes | string |
| scope | formData | comma separated scopes | No | string |
| state | formData | State of API Key. "active" state means key is active and can be used for auth | No | string |
| totp_code | formData | Code from Google Authenticator | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Updates an api key |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Record is not found |
| 422 | Validation errors |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /resource/otp/verify

#### POST
##### Description:

Verify 2FA code

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| code | formData | Code from Google Authenticator | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Verify 2FA code |
| 400 | 2FA has not been enabled for this account or code is missing |
| 401 | Invalid bearer token |
| 422 | Validation errors |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /resource/otp/enable

#### POST
##### Description:

Enable 2FA

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| code | formData | Code from Google Authenticator | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Enable 2FA |
| 400 | 2FA has been enabled for this account or code is missing |
| 401 | Invalid bearer token |
| 422 | Validation errors |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /resource/otp/generate_qrcode

#### POST
##### Description:

Generate qr code for 2FA

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Generate qr code for 2FA |
| 400 | 2FA has been enabled for this account |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /resource/phones/verify

#### POST
##### Description:

Verify a phone

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| phone_number | formData | Phone number with country code | Yes | string |
| verification_code | formData | Verification code from sms | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Verify a phone |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Record is not found |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /resource/phones/send_code

#### POST
##### Description:

Resend activation code

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| phone_number | formData | Phone number with country code | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Resend activation code |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Record is not found |
| 422 | Validation errors |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /resource/phones

#### POST
##### Description:

Add new phone

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| phone_number | formData | Phone number with country code | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Add new phone |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Record is not found |
| 422 | Validation errors |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

#### GET
##### Description:

Returns list of user's phones

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Returns list of user's phones |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /resource/documents

#### POST
##### Description:

Upload a new document for current user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| doc_type | formData | Document type | Yes | string |
| doc_number | formData | Document number | Yes | string |
| upload | formData | Array of Rack::Multipart::UploadedFile | Yes | string |
| doc_expire | formData | Document expiration date | No | date |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Document is uploaded |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 422 | Validation errors |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

#### GET
##### Description:

Return current user documents list

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Return current user documents list |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /resource/profiles

#### POST
##### Description:

Create a profile for current_user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| first_name | formData |  | Yes | string |
| last_name | formData |  | Yes | string |
| dob | formData |  | Yes | date |
| address | formData |  | Yes | string |
| postcode | formData |  | Yes | string |
| city | formData |  | Yes | string |
| country | formData |  | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Create a profile for current_user |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 409 | Profile already exists |
| 422 | Validation errors |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /resource/profiles/me

#### GET
##### Description:

Return profile of current resource owner

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Return profile of current resource owner |
| 401 | Invalid bearer token |
| 404 | User has no profile |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /resource/labels/{key}

#### DELETE
##### Description:

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

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

#### PATCH
##### Description:

Update a label with 'public' scope.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| key | path | Label key. | Yes | string |
| value | formData | Label value. | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Update a label with 'public' scope. |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Record is not found |
| 422 | Validation errors |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

#### GET
##### Description:

Return a label by key.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| key | path | Label key. | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Return a label by key. |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Record is not found |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /resource/labels

#### POST
##### Description:

Create a label with 'public' scope.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| key | formData | Label key. | Yes | string |
| value | formData | Label value. | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Create a label with 'public' scope. |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 422 | Validation errors |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

#### GET
##### Description:

List all labels for current user.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | List all labels for current user. |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /resource/users/password

#### PUT
##### Description:

Sets new account password

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| old_password | formData | Previous account password | Yes | string |
| new_password | formData | User password | Yes | string |
| confirm_password | formData | User password | Yes | string |
| lang | formData | Language in iso-2 format | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Changes password |
| 400 | Required params are empty |
| 404 | Record is not found |
| 422 | Validation errors |

### /resource/users/activity/{topic}

#### GET
##### Description:

Returns user activity

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of activity per page (defaults to 100, maximum is 1000). | No | integer |
| topic | path | Topic of user activity. Allowed: [all, password, session, otp] | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Returns user activity |

### /resource/users/me

#### DELETE
##### Description:

Returns current user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| password | query | Account password | Yes | string |
| otp_code | query | Code from Google Authenticator | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 204 | Returns current user |

#### GET
##### Description:

Returns current user

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Returns current user |

### Models


#### Label

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| key | string | Label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters. | No |
| value | string | Label value. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters. | No |
| scope | string | Label scope: 'public' or 'private' | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### APIKey

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| kid | string | jwt public key | No |
| algorithm | string | cryptographic hash function type | No |
| scope | string | serialized array of scopes | No |
| state | string | active/non-active state of key | No |
| secret | string |  | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### Profile

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| first_name | string |  | No |
| last_name | string |  | No |
| dob | date | Birthday date | No |
| address | string |  | No |
| postcode | string |  | No |
| city | string |  | No |
| country | string |  | No |
| metadata | object | Profile additional fields | No |

#### User

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| email | string |  | No |
| uid | string |  | No |
| role | string |  | No |
| level | integer |  | No |
| otp | boolean | is 2FA enabled for account | No |
| state | string |  | No |

#### UserWithProfile

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| email | string |  | No |
| uid | string |  | No |
| role | string |  | No |
| level | integer |  | No |
| otp | boolean | is 2FA enabled for account | No |
| state | string |  | No |
| profile | [Profile](#profile) |  | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### UserWithFullInfo

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| email | string |  | No |
| uid | string |  | No |
| role | string |  | No |
| level | integer |  | No |
| otp | boolean |  | No |
| state | string |  | No |
| profile | [Profile](#profile) |  | No |
| labels | [Label](#label) |  | No |
| phones | [Phone](#phone) |  | No |
| documents | [Document](#document) |  | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### Phone

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| country | string |  | No |
| number | string |  | No |
| validated_at | s (g) |  | No |

#### Document

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| upload | string | file url | No |
| doc_type | string | document type: passport, driver license | No |
| doc_number | string | document number: AB123123 type | No |
| doc_expire | string | expire date of uploaded documents | No |
| metadata | string | any additional stored data | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### Activity

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| user_ip | string |  | No |
| user_agent | string |  | No |
| topic | string |  | No |
| action | string |  | No |
| result | string |  | No |
| data | string |  | No |
| created_at | string |  | No |