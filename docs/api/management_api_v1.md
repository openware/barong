Management API v1
=================
Management API is server-to-server API with high privileges

**Version:** 1.8.11

### /management_api/v1/otp/sign
---
##### ***POST***
**Summary:** Sign request with barong signature

**Description:** Sign request with barong signature

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| account_uid | formData | Account UID | Yes | string |
| otp_code | formData | Code from Google Authenticator | Yes | integer |
| jwt | formData | RFC 7516 jwt with applogic signature | Yes | Hash |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Sign request with barong signature |

### /management_api/v1/labels/list
---
##### ***POST***
**Summary:** Get all labels assigned to account

**Description:** Get all labels assigned to account

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| account_uid | formData | Account uid | Yes | string |

**Responses**

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Get all labels assigned to account | [Label](#label) |

### /management_api/v1/labels/delete
---
##### ***POST***
**Summary:** Delete a label with 'private' scope

**Description:** Delete a label with 'private' scope

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| account_uid | formData | Account uid | Yes | string |
| key | formData | Label key. | Yes | string |

**Responses**

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Delete a label with 'private' scope | [Label](#label) |

### /management_api/v1/labels
---
##### ***PUT***
**Summary:** Update a label with 'private' scope

**Description:** Update a label with 'private' scope

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| account_uid | formData | Account uid | Yes | string |
| key | formData | Label key. | Yes | string |
| value | formData | Label value. | Yes | string |

**Responses**

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Update a label with 'private' scope | [Label](#label) |

##### ***POST***
**Summary:** Create a label with 'private' scope and assigns to account

**Description:** Create a label with 'private' scope and assigns to account

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| account_uid | formData | Account uid | Yes | string |
| key | formData | Label key. | Yes | string |
| value | formData | Label value. | Yes | string |

**Responses**

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create a label with 'private' scope and assigns to account | [Label](#label) |

### /management_api/v1/accounts/get
---
##### ***POST***
**Summary:** Get account and profile information

**Description:** Get account and profile information

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | Account uid | Yes | string |

**Responses**

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Get account and profile information | [AccountWithProfile](#accountwithprofile) |

### /management_api/v1/timestamp
---
##### ***POST***
**Summary:** Returns server time in seconds since Unix epoch.

**Description:** Returns server time in seconds since Unix epoch.

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Returns server time in seconds since Unix epoch. |

### Models
---

### Label

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| key | string | Label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters. | No |
| value | string | Label value. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters. | No |
| scope | string | Label scope: 'public' or 'private' | No |
| created_at | string |  | No |
| updated_at | string |  | No |

### AccountWithProfile

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| email | integer |  | No |
| role | string |  | No |
| otp_enabled | boolean | is 2FA enabled for account | No |
| state | string |  | No |
| profile | [Profile](#profile) |  | No |
| created_at | string |  | No |
| updated_at | string |  | No |

### Profile

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
