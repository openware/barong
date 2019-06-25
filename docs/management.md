# Barong
Management API for barong OAuth server

## Version: 2.0.30-alpha

### Security
**BearerToken**  

|jwt|*undefined*|
|---|---|
|Description|Bearer Token authentication|
|Name|Authorization|
|In|header|

### /labels/delete

#### POST
##### Description:

Delete a label with 'private' scope

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| user_uid | formData | User uid | Yes | string |
| key | formData | Label key. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Delete a label with 'private' scope | [Label](#label) |

### /labels

#### PUT
##### Description:

Update a label with 'private' scope

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| user_uid | formData | User uid | Yes | string |
| key | formData | Label key. | Yes | string |
| value | formData | Label value. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Update a label with 'private' scope | [Label](#label) |

#### POST
##### Description:

Create a label with 'private' scope and assigns to users

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| user_uid | formData | User uid | Yes | string |
| key | formData | Label key. | Yes | string |
| value | formData | Label value. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create a label with 'private' scope and assigns to users | [Label](#label) |

### /labels/list

#### POST
##### Description:

Get all labels assigned to users

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| user_uid | formData | User uid | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Get all labels assigned to users | [Label](#label) |

### /users/import

#### POST
##### Description:

Imports an existing user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| email | formData | User Email | Yes | string |
| password_digest | formData | User Password Hash | Yes | string |
| phone | formData |  | No | string |
| first_name | formData |  | No | string |
| last_name | formData |  | No | string |
| dob | formData | Birthday date | No | date |
| address | formData |  | No | string |
| postcode | formData |  | No | string |
| city | formData |  | No | string |
| country | formData |  | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Imports an existing user | [UserWithProfile](#userwithprofile) |

### /users

#### POST
##### Description:

Creates new user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| email | formData | User Email | Yes | string |
| password | formData | User Password | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Creates new user | [UserWithProfile](#userwithprofile) |

### /users/list

#### POST
##### Description:

Returns array of users as collection

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Returns array of users as collection | [User](#user) |

### /users/get

#### POST
##### Description:

Get users and profile information

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | User uid | No | string |
| email | formData | User email | No | string |
| phone_num | formData | User phone number | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Get users and profile information | [UserWithProfile](#userwithprofile) |

### /otp/sign

#### POST
##### Description:

Sign request with barong signature

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| user_uid | formData | Account UID | Yes | string |
| otp_code | formData | Code from Google Authenticator | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Sign request with barong signature |

### /timestamp

#### POST
##### Description:

Returns server time in seconds since Unix epoch.

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Returns server time in seconds since Unix epoch. |

### Models


#### Label

Get all labels assigned to users

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| key | string | Label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters. | No |
| value | string | Label value. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters. | No |
| scope | string | Label scope: 'public' or 'private' | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### UserWithProfile

Get users and profile information

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

Returns array of users as collection

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| email | string |  | No |
| uid | string |  | No |
| role | string |  | No |
| level | integer |  | No |
| otp | boolean | is 2FA enabled for account | No |
| state | string |  | No |

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