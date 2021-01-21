# Barong
RESTful AdminAPI for barong OAuth server

## Version: 2.7.0

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

| Code | Description |
| ---- | ----------- |
| 204 | Deletes user's data storage record |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /api/v2/barong/admin/users/{uid}

#### GET
##### Description

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

| Code | Description |
| ---- | ----------- |
| 200 | Returns array of users with pending or replaced documents as paginated collection |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

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
| 200 | Update user attributes |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

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

| Code | Description |
| ---- | ----------- |
| 200 | Returns array of users as paginated collection |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

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
| 201 | Update user role |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

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
| 201 | Update user attributes |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

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
| 204 | Deletes label for user |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

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
##### Description

Adds label for user

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
| 201 | Adds label for user |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

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

| Code | Description |
| ---- | ----------- |
| 200 | Returns array of users as paginated collection |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

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
| 201 | Update user label value |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Record is not found |
| 422 | Validation errors |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /api/v2/barong/admin/users/labels/list

#### GET
##### Description

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

### /api/v2/barong/admin/users/comments

#### DELETE
##### Description

Delete user's comment

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | query | comment uniq id | Yes | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 204 | Delete user's comment |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

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

| Code | Description |
| ---- | ----------- |
| 200 | Edit user's comment |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

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

| Code | Description |
| ---- | ----------- |
| 201 | Adds new user's comment |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

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

| Code | Description |
| ---- | ----------- |
| 200 | List all api keys for selected account. |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

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
| 200 | Update Permission |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

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
| 204 | Deletes permission |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

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
| 201 | Create permission |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

#### GET
##### Description

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

| Code | Description |
| ---- | ----------- |
| 200 | Returns array of activities as paginated collection |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

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

| Code | Description |
| ---- | ----------- |
| 200 | Returns array of activities as paginated collection |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

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

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

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
| 204 | Delete restriction |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

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
| 200 | Update restriction |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

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
| 201 | Create restriction |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

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

| Code | Description |
| ---- | ----------- |
| 200 | Returns array of restrictions as a paginated collection |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

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
| 201 | Create whitelink |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

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

| Code | Description |
| ---- | ----------- |
| 201 | Create a profile for user |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 422 | Validation errors |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

#### PUT
##### Description

Verify user's profile

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData |  | Yes | string |
| state | formData |  | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Verify user's profile |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 422 | Validation errors |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

#### GET
##### Description

Return all profiles

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Return all profiles |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /api/v2/barong/admin/levels

#### GET
##### Description

Returns array of permissions as paginated collection

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Returns array of permissions as paginated collection |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --- | --- |
| BearerToken | |

### /api/v2/barong/admin/abilities

#### GET
##### Description

Get all roles and admin_permissions of barong cancan.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get all roles and admin_permissions of barong cancan. |

### Models

#### API_V2_Admin_Entities_ActivityWithUser

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| user_ip | string |  | No |
| user_agent | string |  | No |
| topic | string |  | No |
| action | string |  | No |
| result | string |  | No |
| data | string |  | No |
| user | [API_V2_Entities_User](#api_v2_entities_user) |  | No |
| created_at | string |  | No |

#### API_V2_Entities_User

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| email | string |  | No |
| nickname | string | User nickname | No |
| uid | string |  | No |
| role | string |  | No |
| level | integer |  | No |
| otp | boolean | is 2FA enabled for account | No |
| state | string |  | No |
| referral_uid | string | UID of referrer | No |
| data | string | additional phone and profile info | No |

#### API_V2_Admin_Entities_AdminActivity

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| user_ip | string |  | No |
| user_agent | string |  | No |
| topic | string |  | No |
| action | string |  | No |
| result | string |  | No |
| data | string |  | No |
| admin | [API_V2_Entities_User](#api_v2_entities_user) |  | No |
| target | [API_V2_Entities_User](#api_v2_entities_user) |  | No |
| created_at | string |  | No |

#### API_V2_Admin_Entities_Document

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| upload | string | file url | No |
| doc_type | string | document type: passport, driver license | No |
| doc_number | string | document number: AB123123 type | No |
| doc_expire | string | expire date of uploaded documents | No |
| metadata | string | any additional stored data | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Admin_Entities_Phone

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| country | string |  | No |
| number | string |  | No |
| validated_at | s (g) |  | No |

#### API_V2_Admin_Entities_Profile

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| first_name | string |  | No |
| last_name | string | Last name | No |
| dob | date | Birthday date | No |
| address | string |  | No |
| postcode | string |  | No |
| city | string |  | No |
| country | string |  | No |
| state | string |  | No |
| metadata | object | Profile additional fields | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Admin_Entities_UserWithKYC

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| email | string |  | No |
| nickname | string | User nickname | No |
| uid | string |  | No |
| role | string |  | No |
| level | integer |  | No |
| otp | boolean |  | No |
| state | string |  | No |
| data | string | additional phone and profile info | No |
| profiles | [API_V2_Admin_Entities_Profile](#api_v2_admin_entities_profile) |  | No |
| labels | [API_V2_Entities_AdminLabelView](#api_v2_entities_adminlabelview) |  | No |
| phones | [API_V2_Admin_Entities_Phone](#api_v2_admin_entities_phone) |  | No |
| documents | [API_V2_Admin_Entities_Document](#api_v2_admin_entities_document) |  | No |
| data_storages | [API_V2_Entities_DataStorage](#api_v2_entities_datastorage) |  | No |
| comments | [API_V2_Entities_Comment](#api_v2_entities_comment) |  | No |
| referral_uid | string | UID of referrer | No |
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

#### API_V2_Entities_DataStorage

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| title | string | any additional data title | No |
| data | string | any additional data json key:value pairs | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_Comment

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | comment id | No |
| author_uid | string | comment author | No |
| title | string | comment title | No |
| data | string | comment plain text | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Admin_Entities_UserWithProfile

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| email | string |  | No |
| nickname | string | User nickname | No |
| uid | string |  | No |
| role | string |  | No |
| level | integer |  | No |
| otp | boolean | is 2FA enabled for account | No |
| state | string |  | No |
| data | string | additional phone and profile info | No |
| profiles | [API_V2_Admin_Entities_Profile](#api_v2_admin_entities_profile) |  | No |
| referral_uid | string | UID of referrer | No |
| created_at | string |  | No |
| updated_at | string |  | No |
