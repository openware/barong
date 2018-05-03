Barong
======
API for barong OAuth server 

**Version:** 1.8.0.alpha

### /v1/accounts/confirm
---
##### ***POST***
**Summary:** Confirms new account

**Description:** Confirms new account

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| confirmation_token | formData | Token from email | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Confirms new account |

### /v1/accounts
---
##### ***POST***
**Summary:** Creates new account

**Description:** Creates new account

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| email | formData | Account Email | Yes | string |
| password | formData | Account Password | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Creates new account |

### /v1/accounts/password
---
##### ***PUT***
**Summary:** Change user's password

**Description:** Change user's password

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| old_password | formData |  | Yes | string |
| new_password | formData |  | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Change user's password |

### /v1/accounts/me
---
##### ***GET***
**Summary:** Return information about current resource owner

**Description:** Return information about current resource owner

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Return information about current resource owner |

### /v1/profiles
---
##### ***POST***
**Summary:** Create a profile for current_account

**Description:** Create a profile for current_account

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| first_name | formData |  | Yes | string |
| last_name | formData |  | Yes | string |
| dob | formData |  | Yes | date |
| address | formData |  | Yes | string |
| postcode | formData |  | Yes | string |
| city | formData |  | Yes | string |
| country | formData |  | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Create a profile for current_account |

### /v1/profiles/me
---
##### ***GET***
**Summary:** Return profile of current resource owner

**Description:** Return profile of current resource owner

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Return profile of current resource owner |

### /v1/security/verify_api_key
---
##### ***POST***
**Summary:** Verify API key

**Description:** Verify API key

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | API Key uid | Yes | string |
| account_uid | formData | Account uid | No | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Verify API key |

### /v1/security/reset_password
---
##### ***PUT***
**Summary:** Sets new account password

**Description:** Sets new account password

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| reset_password_token | formData | Token from email | Yes | string |
| password | formData | Account password | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Sets new account password |

##### ***POST***
**Summary:** Send reset password instructions

**Description:** Send reset password instructions

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| email | formData | account email | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Send reset password instructions |

### /v1/security/verify_code
---
##### ***POST***
**Summary:** Verify 2FA code

**Description:** Verify 2FA code

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| code | formData | Code from Google Authenticator | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Verify 2FA code |

### /v1/security/enable_2fa
---
##### ***POST***
**Summary:** Enable 2FA

**Description:** Enable 2FA

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| code | formData | Code from Google Authenticator | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Enable 2FA |

### /v1/security/generate_qrcode
---
##### ***POST***
**Summary:** Generate qr code for 2FA

**Description:** Generate qr code for 2FA

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Generate qr code for 2FA |

### /v1/security/renew
---
##### ***POST***
**Summary:** Renews JWT if current JWT is valid

**Description:** Renews JWT if current JWT is valid

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Renews JWT if current JWT is valid |

### /v1/documents
---
##### ***POST***
**Summary:** Upload a new document for current user

**Description:** Upload a new document for current user

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| doc_expire | formData |  | Yes | string |
| doc_type | formData |  | Yes | string |
| doc_number | formData |  | Yes | string |
| upload | formData |  | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Upload a new document for current user |

##### ***GET***
**Summary:** Return current user documents list

**Description:** Return current user documents list

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Return current user documents list |

### /v1/phones/verify
---
##### ***POST***
**Summary:** Verify a phone

**Description:** Verify a phone

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| phone_number | formData | Phone number with country code | Yes | string |
| verification_code | formData | Verification code from sms | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Verify a phone |

### /v1/phones/send_code
---
##### ***POST***
**Summary:** Resend activation code

**Description:** Resend activation code

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| phone_number | formData | Phone number with country code | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Resend activation code |

### /v1/phones
---
##### ***POST***
**Summary:** Add new phone

**Description:** Add new phone

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| phone_number | formData | Phone number with country code | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Add new phone |

### /v1/sessions/generate_jwt
---
##### ***POST***
**Summary:** Validates client jwt and generates peatio session jwt

**Description:** Validates client jwt and generates peatio session jwt

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| key_uid | formData |  | Yes | string |
| jwt_token | formData |  | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Validates client jwt and generates peatio session jwt |

### /v1/sessions
---
##### ***POST***
**Summary:** Start a new session

**Description:** Start a new session

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| email | formData |  | Yes | string |
| password | formData |  | Yes | string |
| application_id | formData |  | Yes | string |
| expires_in | formData |  | No | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Start a new session |

### /v1/labels/{key}
---
##### ***DELETE***
**Summary:** Delete a label  with 'public' scope.

**Description:** Delete a label  with 'public' scope.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| key | path | Label key. | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 204 | Delete a label  with 'public' scope. |

##### ***PATCH***
**Summary:** Update a label with 'public' scope.

**Description:** Update a label with 'public' scope.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| key | path | Label key. | Yes | string |
| value | formData | Label value. | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Update a label with 'public' scope. |

##### ***GET***
**Summary:** Return a label by key.

**Description:** Return a label by key.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| key | path | Label key. | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Return a label by key. |

### /v1/labels
---
##### ***POST***
**Summary:** Create a label with 'public' scope.

**Description:** Create a label with 'public' scope.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| key | formData | Label key. | Yes | string |
| value | formData | Label value. | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Create a label with 'public' scope. |

##### ***GET***
**Summary:** List all labels for current account.

**Description:** List all labels for current account.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | List all labels for current account. |

### /v1/api_keys/{uid}
---
##### ***DELETE***
**Summary:** Delete an api key

**Description:** Delete an api key

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | path |  | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 204 | Delete an api key |

##### ***PATCH***
**Summary:** Updates an api key

**Description:** Updates an api key

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | path |  | Yes | string |
| public_key | formData |  | No | string |
| scopes | formData | comma separated scopes | No | string |
| expires_in | formData | expires_in duration in seconds | No | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Updates an api key |

##### ***GET***
**Summary:** Return a api key by uid

**Description:** Return a api key by uid

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | path |  | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Return a api key by uid |

### /v1/api_keys
---
##### ***POST***
**Summary:** Create an api key

**Description:** Create an api key

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| public_key | formData |  | Yes | string |
| scopes | formData | comma separated scopes | No | string |
| expires_in | formData | expires_in duration in seconds | No | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Create an api key |

##### ***GET***
**Summary:** List all api keys for current account.

**Description:** List all api keys for current account.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | List all api keys for current account. |
