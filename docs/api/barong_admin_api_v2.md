# Barong
RESTful AdminAPI for barong OAuth server

## Version: 2.7.0

### Security
**BearerToken**  

|basic|*Basic*|
|---|---|
|Description|Bearer Token authentication|
|Name|Authorization|
|In|header|

### /api/v2/barong/admin/users/data_storage

#### DELETE
##### Description

Deletes user's data storage record

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | query | user uniq id | Yes | string |
| title | query | data storage uniq title | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 204 | Deletes user's data storage record | [API_V2_Admin_Entities_UserWithKYC](#api_v2_admin_entities_userwithkyc) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/users/{uid}

#### GET
##### Description

Returns user info

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | path | user uniq id | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns user info | [API_V2_Admin_Entities_UserWithKYC](#api_v2_admin_entities_userwithkyc) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/users/documents/pending

#### GET
##### Description

Returns array of users with pending or replaced documents as paginated collection

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
| from | query | An integer represents the seconds elapsed since Unix epoch.If set, only records FROM the time will be retrieved. | No | integer |
| to | query | An integer represents the seconds elapsed since Unix epoch.If set, only records BEFORE the time will be retrieved. | No | integer |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns array of users with pending or replaced documents as paginated collection | [API_V2_Entities_User](#api_v2_entities_user) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/users

#### PUT
##### Description

Update user attributes

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | user uniq id | Yes | string |
| email | formData | User Email | No | string |
| state | formData | user state | No | string |
| otp | formData | user 2fa status | No | boolean |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | User attributes were created |
| 401 | Invalid bearer token |

#### GET
##### Description

Returns array of users as paginated collection

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| extended | query | When true endpoint returns full information about users | No | boolean |
| uid | query |  | No | string |
| email | query |  | No | string |
| role | query |  | No | string |
| country | query |  | No | string |
| level | query |  | No | integer |
| state | query |  | No | string |
| range | query |  | No | string |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |
| from | query | An integer represents the seconds elapsed since Unix epoch.If set, only records FROM the time will be retrieved. | No | integer |
| to | query | An integer represents the seconds elapsed since Unix epoch.If set, only records BEFORE the time will be retrieved. | No | integer |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns array of users as paginated collection | [API_V2_Entities_User](#api_v2_entities_user) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/users/role

#### POST
##### Description

Update user role

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | user uniq id | Yes | string |
| role | formData | user role | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | User role was created |
| 401 | Invalid bearer token |

### /api/v2/barong/admin/users/update

#### POST
##### Description

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
| 200 | User attributes were updated |
| 401 | Invalid bearer token |

### /api/v2/barong/admin/users/labels

#### DELETE
##### Description

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
| 204 | Label was deleted |
| 401 | Invalid bearer token |

#### PUT
##### Description

Update user label scope

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | user uniq id | Yes | string |
| key | formData | Label key. | Yes | string |
| scope | formData | label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters. | Yes | string |
| description | formData | label description. [A-Za-z0-9_-] should be used. max - 255 characters. | No | string |
| value | formData | Label value. | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Label was updated |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Record is not found |
| 422 | Validation errors |

#### POST
##### Description

Add label for user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | user uniq id | Yes | string |
| key | formData | label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters. | Yes | string |
| value | formData | label value. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters. | Yes | string |
| description | formData | label description. [A-Za-z0-9_-] should be used. max - 255 characters. | No | string |
| scope | formData | Label scope: 'public' or 'private'. Default is public | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Label was created |
| 401 | Invalid bearer token |

#### GET
##### Description

Returns array of users as paginated collection

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| key | query | Label key | Yes | string |
| value | query | Label value | Yes | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns array of users as paginated collection | [API_V2_Entities_User](#api_v2_entities_user) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/users/labels/update

#### POST
##### Description

Update user label value

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | user uniq id | Yes | string |
| key | formData | Label key. | Yes | string |
| scope | formData | label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters. | Yes | string |
| value | formData | Label value. | Yes | string |
| description | formData | label description. [A-Za-z0-9_-] should be used. max - 255 characters. | No | string |
| replace | formData | When true label will be created if not exist | No | boolean |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Label was updated |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Record is not found |
| 422 | Validation errors |

### /api/v2/barong/admin/users/labels/list

#### GET
##### Description

Returns existing labels keys and values

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Returns existing labels keys and values |
| 401 | Invalid bearer token |

### /api/v2/barong/admin/users/comments

#### DELETE
##### Description

Delete user's comment

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | query | comment uniq id | Yes | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 204 | Delete user's comment | [API_V2_Admin_Entities_UserWithKYC](#api_v2_admin_entities_userwithkyc) |
| 401 | Invalid bearer token |  |

#### PUT
##### Description

Edit user's comment

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | formData | comment uniq id | Yes | integer |
| title | formData | comment title | No | string |
| data | formData | comment data | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Edit user's comment | [API_V2_Admin_Entities_UserWithKYC](#api_v2_admin_entities_userwithkyc) |
| 401 | Invalid bearer token |  |

#### POST
##### Description

Adds new user's comment

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | user uniq id | Yes | string |
| title | formData | comment uniq title | Yes | string |
| data | formData | comment data | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Adds new user's comment | [API_V2_Admin_Entities_UserWithKYC](#api_v2_admin_entities_userwithkyc) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/api_keys

#### GET
##### Description

List all api keys for selected account.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | query | user uniq id | Yes | string |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | List all api keys for selected account. | [API_V2_Entities_APIKey](#api_v2_entities_apikey) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/permissions

#### PUT
##### Description

Update Permission

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | formData | Permission id | Yes | integer |
| role | formData | permission field - role | No | string |
| verb | formData | permission field - request verb | No | string |
| path | formData | permission field - request path | No | string |
| action | formData |  | No | string |
| topic | formData |  | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Permission was updated |
| 401 | Invalid bearer token |

#### DELETE
##### Description

Deletes permission

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | query | permission id | Yes | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 204 | Permission was deleted |
| 401 | Invalid bearer token |

#### POST
##### Description

Create permission

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| role | formData |  | Yes | string |
| verb | formData |  | Yes | string |
| path | formData |  | Yes | string |
| action | formData |  | Yes | string |
| topic | formData |  | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Permission was created |
| 401 | Invalid bearer token |

#### GET
##### Description

Returns array of permissions as paginated collection

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns array of permissions as paginated collection | [API_V2_Entities_Permission](#api_v2_entities_permission) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/activities/admin

#### GET
##### Description

Returns array of activities as paginated collection

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| topic | query |  | No | string |
| action | query |  | No | string |
| uid | query |  | No | string |
| email | query |  | No | string |
| from | query | An integer represents the seconds elapsed since Unix epoch.If set, only records FROM the time will be retrieved. | No | integer |
| to | query | An integer represents the seconds elapsed since Unix epoch.If set, only records BEFORE the time will be retrieved. | No | integer |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |
| target_uid | query |  | No | string |
| range | query |  | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns array of activities as paginated collection | [API_V2_Admin_Entities_AdminActivity](#api_v2_admin_entities_adminactivity) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/activities

#### GET
##### Description

Returns array of activities as paginated collection

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| topic | query |  | No | string |
| action | query |  | No | string |
| uid | query |  | No | string |
| email | query |  | No | string |
| from | query | An integer represents the seconds elapsed since Unix epoch.If set, only records FROM the time will be retrieved. | No | integer |
| to | query | An integer represents the seconds elapsed since Unix epoch.If set, only records BEFORE the time will be retrieved. | No | integer |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns array of activities as paginated collection | [API_V2_Admin_Entities_ActivityWithUser](#api_v2_admin_entities_activitywithuser) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/metrics

#### GET
##### Description

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

### /api/v2/barong/admin/restrictions

#### DELETE
##### Description

Delete restriction

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | query | Restriction id | Yes | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 204 | Restriction was deleted |
| 401 | Invalid bearer token |

#### PUT
##### Description

Update restriction

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | formData | Restriction id | Yes | integer |
| scope | formData |  | No | string |
| category | formData |  | No | string |
| value | formData |  | No | string |
| state | formData |  | No | string |
| code | formData |  | No | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Restriction was updated |
| 401 | Invalid bearer token |

#### POST
##### Description

Create restriction

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| scope | formData |  | Yes | string |
| value | formData |  | Yes | string |
| category | formData |  | Yes | string |
| state | formData |  | No | string |
| code | formData |  | No | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Restriction was created |
| 401 | Invalid bearer token |

#### GET
##### Description

Returns array of restrictions as a paginated collection

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| scope | query |  | No | string |
| category | query |  | No | string |
| range | query |  | No | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns array of restrictions as a paginated collection | [API_V2_Entities_Restriction](#api_v2_entities_restriction) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/restrictions/whitelink

#### POST
##### Description

Create whitelink

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| expire_time | formData | link will be active for (Time.now + expire_time in following range) | No | integer |
| range | formData | In combination with expire_time gives full controll over token expiration | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Created whitelink |
| 401 | Invalid bearer token |

### /api/v2/barong/admin/profiles

#### POST
##### Description

Create a profile for user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData |  | Yes | string |
| first_name | formData |  | No | string |
| last_name | formData |  | No | string |
| dob | formData |  | No | date |
| address | formData |  | No | string |
| postcode | formData |  | No | string |
| city | formData |  | No | string |
| country | formData |  | No | string |
| metadata | formData | Any additional key: value pairs in json string format | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create a profile for user | [API_V2_Admin_Entities_Profile](#api_v2_admin_entities_profile) |
| 400 | Required params are empty |  |
| 401 | Invalid bearer token |  |
| 422 | Validation errors |  |

#### PUT
##### Description

Verify user's profile

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData |  | Yes | string |
| state | formData |  | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Verify user's profile | [API_V2_Admin_Entities_Profile](#api_v2_admin_entities_profile) |
| 400 | Required params are empty |  |
| 401 | Invalid bearer token |  |
| 422 | Validation errors |  |

#### GET
##### Description

Return all profiles

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Return all profiles | [API_V2_Admin_Entities_Profile](#api_v2_admin_entities_profile) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/levels

#### GET
##### Description

Returns array of permissions as paginated collection

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns array of permissions as paginated collection | [API_V2_Entities_Level](#api_v2_entities_level) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/abilities

#### GET
##### Description

Get all roles and admin_permissions of barong cancan.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get all roles and admin_permissions of barong cancan. |

### Models

#### API_V2_Admin_Entities_UserWithKYC

Adds new user's comment

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
| profiles | [API_V2_Admin_Entities_Profile](#api_v2_admin_entities_profile) |  | No |
| labels | [API_V2_Entities_AdminLabelView](#api_v2_entities_adminlabelview) |  | No |
| phones | [API_V2_Admin_Entities_Phone](#api_v2_admin_entities_phone) |  | No |
| documents | [API_V2_Admin_Entities_Document](#api_v2_admin_entities_document) |  | No |
| data_storages | [API_V2_Entities_DataStorage](#api_v2_entities_datastorage) |  | No |
| comments | [API_V2_Entities_Comment](#api_v2_entities_comment) |  | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Admin_Entities_Profile

Return all profiles

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| first_name | string | First Name | No |
| last_name | string | Last name | No |
| dob | date | Birth date | No |
| address | string | Address | No |
| postcode | string | Address Postcode | No |
| city | string | City name | No |
| country | string | Country name | No |
| state | string | Profile state: drafted, submitted, verified, rejected | No |
| metadata | object | Profile additional fields | No |
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

#### API_V2_Admin_Entities_Phone

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| country | string | Phone country | No |
| number | string | Phone number | No |
| validated_at | s (g) | Phone validation date | No |

#### API_V2_Admin_Entities_Document

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| upload | string | File url | No |
| doc_type | string | Document type: passport, driver license, utility bill, identity card, institutional, address, residental | No |
| doc_number | string | document number: AB123123 type | No |
| doc_expire | string | Expire date of uploaded documents | No |
| metadata | string | Any additional stored data | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_DataStorage

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| title | string | Any additional data title | No |
| data | string | Any additional data json key:value pairs | No |
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

#### API_V2_Entities_User

Returns array of users as paginated collection

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

#### API_V2_Entities_APIKey

List all api keys for selected account.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| kid | string | JWT public key | No |
| algorithm | string | Cryptographic hash function type | No |
| scope | string | Serialized array of scopes | No |
| state | string | active/non-active state of key | No |
| secret | string | Api key secret | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_Permission

Returns array of permissions as paginated collection

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Permission id | No |
| action | string | Permission action: accept (allow access (drop access), audit (record activity) | No |
| role | string | Permission user role | No |
| verb | string | Permission verb: put, post, delete, get | No |
| path | string | API path | No |
| topic | string | Permission topic: general, session etc | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Admin_Entities_AdminActivity

Returns array of activities as paginated collection

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| user_ip | string | User IP | No |
| user_agent | string | User Browser Agent | No |
| topic | string | Defined topic (session, adjustments) or general by default | No |
| action | string | API action: POST => 'create', PUT => 'update', GET => 'read', DELETE => 'delete', PATCH => 'update' or system if there is no match of HTTP method | No |
| result | string | Status of API response: succeed, failed, denied | No |
| data | string | Parameters which was sent to specific API endpoint | No |
| admin | [API_V2_Entities_User](#api_v2_entities_user) |  | No |
| target | [API_V2_Entities_User](#api_v2_entities_user) |  | No |
| created_at | string |  | No |

#### API_V2_Admin_Entities_ActivityWithUser

Returns array of activities as paginated collection

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| user_ip | string | User IP | No |
| user_agent | string | User Browser Agent | No |
| topic | string | Defined topic (session, adjustments) or general by default | No |
| action | string | API action: POST => 'create', PUT => 'update', GET => 'read', DELETE => 'delete', PATCH => 'update' or system if there is no match of HTTP method | No |
| result | string | Status of API response: succeed, failed, denied | No |
| data | string | Parameters which was sent to specific API endpoint | No |
| user | [API_V2_Entities_User](#api_v2_entities_user) |  | No |
| created_at | string |  | No |

#### API_V2_Entities_Restriction

Returns array of restrictions as a paginated collection

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Restriction id | No |
| category | string | Restriction categories: blacklist, maintenance, whitelist, blocklogin | No |
| scope | string | Restriction scopes: continent, country, ip, ip_subnet, all | No |
| value | string | Restriction value: IP address, country abbreviation, all | No |
| code | integer | Restriction codes: {"continent"=>423, "country"=>423, "ip_subnet"=>403, "ip"=>401, "all"=>401} | No |
| state | string | Restriction states: disabled, enabled | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_Level

Returns array of permissions as paginated collection

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Level identifier, level number | No |
| key | string | Label key. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters. | No |
| value | string | Label value. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters. | No |

#### API_V2_Admin_Entities_UserWithProfile

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
| profiles | [API_V2_Admin_Entities_Profile](#api_v2_admin_entities_profile) |  | No |
| created_at | string |  | No |
| updated_at | string |  | No |
