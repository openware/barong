# Barong
Management API for barong OAuth server

## Version: 2.4.0

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
| 201 | Delete a label with 'private' scope | [AdminLabelView](#adminlabelview) |

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
| description | formData | Label desc. | No | string |
| replace | formData | When true label will be created if not exist | No | Boolean |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Update a label with 'private' scope | [AdminLabelView](#adminlabelview) |

#### POST
##### Description:

Create a label with 'private' scope and assigns to users

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| user_uid | formData | User uid | Yes | string |
| key | formData | Label key. | Yes | string |
| value | formData | Label value. | Yes | string |
| description | formData | Label desc. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create a label with 'private' scope and assigns to users | [AdminLabelView](#adminlabelview) |

### /labels/list

#### POST
##### Description:

Get user collection filtered on label attributes

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| user_uid | formData | User uid | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Get user collection filtered on label attributes | [Label](#label) |

### /labels/filter/users

#### POST
##### Description:

Get all labels assigned to users

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| key | formData | Label key. | Yes | string |
| value | formData | Label value. | No | string |
| scope | formData | Label scope. | No | string |
| extended | formData | When true endpoint returns full information about users | No | Boolean |
| range | formData |  | No | string |
| page | formData | Page number (defaults to 1). | No | integer |
| limit | formData | Number of users per page (defaults to 100, maximum is 100). | No | integer |

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
| referral_uid | formData | Referral uid | No | string |
| phone | formData |  | No | string |
| first_name | formData |  | No | string |
| last_name | formData |  | No | string |
| dob | formData | Birthday date | No | date |
| address | formData |  | No | string |
| postcode | formData |  | No | string |
| city | formData |  | No | string |
| country | formData |  | No | string |
| state | formData |  | No | string |

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
| referral_uid | formData | Referral uid | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Creates new user | [UserWithProfile](#userwithprofile) |

### /users/list

#### POST
##### Description:

Returns array of users as collection

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| extended | formData | When true endpoint returns full information about users | No | Boolean |
| range | formData |  | No | string |
| from | formData | An integer represents the seconds elapsed since Unix epoch.If set, only records FROM the time will be retrieved. | No | integer |
| to | formData | An integer represents the seconds elapsed since Unix epoch.If set, only records BEFORE the time will be retrieved. | No | integer |
| page | formData | Page number (defaults to 1). | No | integer |
| limit | formData | Number of users per page (defaults to 100, maximum is 100). | No | integer |

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

### /otp/check

#### POST
##### Description:

Check if otp code is valid

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| user_uid | formData | Account UID | Yes | string |
| otp_code | formData | Code from Google Authenticator | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Success! OTP Code is valid |

### /documents

#### POST
##### Description:

Push documents to barong DB

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | User uid | Yes | string |
| doc_type | formData | Document type | Yes | string |
| doc_number | formData | Document number | Yes | string |
| filename | formData | Document name | Yes | string |
| file_ext | formData | Document file extension | Yes | string |
| upload | formData | Base64 encoded document | Yes | string |
| doc_expire | formData | Document expiration date | No | date |
| update_labels | formData | If set to false, user label will not be created/updated | No | Boolean |
| metadata | formData | Any additional key: value pairs in json string format | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Push documents to barong DB | [UserWithProfile](#userwithprofile) |

### /timestamp

#### POST
##### Description:

Returns server time in seconds since Unix epoch.

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Returns server time in seconds since Unix epoch. |

### Models


#### AdminLabelView

Create a label with 'private' scope and assigns to users

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| key | string | Label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters. | No |
| value | string | Label value. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters. | No |
| scope | string | Label scope: 'public' or 'private' | No |
| description | string | Label desc: json string with any additional information | No |
| created_at | string |  | No |
| updated_at | string |  | No |

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

Push documents to barong DB

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| email | string |  | No |
| uid | string |  | No |
| role | string |  | No |
| level | integer |  | No |
| otp | boolean | is 2FA enabled for account | No |
| state | string |  | No |
| data | string | additional phone and profile info | No |
| profiles | [Profile](#profile) |  | No |
| referral_uid | string | UID of referrer | No |
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
| state | string |  | No |
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
| referral_uid | string | UID of referrer | No |
| data | string | additional phone and profile info | No |

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
| referral_uid | string | UID of referrer | No |
| csrf_token | string | csrf protection token | No |
| data | string | additional phone and profile info | No |
| created_at | string |  | No |
| updated_at | string |  | No |
| labels | [Label](#label) |  | No |
| phones | [Phone](#phone) |  | No |
| profiles | [Profile](#profile) |  | No |
| data_storages | [DataStorage](#datastorage) |  | No |

#### Phone

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| country | string |  | No |
| number | string |  | No |
| validated_at | s (g) |  | No |

#### DataStorage

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| title | string | any additional data title | No |
| data | string | any additional data json key:value pairs | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### UserWithKYC

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| email | string |  | No |
| uid | string |  | No |
| role | string |  | No |
| level | integer |  | No |
| otp | boolean |  | No |
| state | string |  | No |
| data | string | additional phone and profile info | No |
| profiles | [Profile](#profile) |  | No |
| labels | [AdminLabelView](#adminlabelview) |  | No |
| phones | [Phone](#phone) |  | No |
| documents | [Document](#document) |  | No |
| data_storages | [DataStorage](#datastorage) |  | No |
| referral_uid | string | UID of referrer | No |
| created_at | string |  | No |
| updated_at | string |  | No |

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
