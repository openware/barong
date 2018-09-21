---
title: Barong v1.8.26
language_tabs:
  - http: HTTP
  - shell: Curl
  - javascript: JavaScript
toc_footers: []
includes: []
search: true
highlight_theme: darkula
headingLevel: 2


---


<h1 id="Barong">Barong v1.8.26</h1>


> Scroll down for code samples, example requests and responses. Select a language for code samples from the tabs above or the mobile navigation menu.


API for barong OAuth server 


Base URLs:


* <a href="//localhost:3000/api">//localhost:3000/api</a>


# Authentication


* API Key (BearerToken)
    - Parameter Name: **Authorization**, in: header. Bearer Token authentication


<h1 id="Barong-accounts">accounts</h1>


Operations about accounts


## postV1AccountsUnlock


<a id="opIdpostV1AccountsUnlock"></a>


> Code samples


```http
POST //localhost:3000/api/v1/accounts/unlock HTTP/1.1
Host: null
Content-Type: application/x-www-form-urlencoded


```


```shell
# You can also use wget
curl -X POST //localhost:3000/api/v1/accounts/unlock \
  -H 'Content-Type: application/x-www-form-urlencoded'


```


```javascript
var headers = {
  'Content-Type':'application/x-www-form-urlencoded'


};


$.ajax({
  url: '//localhost:3000/api/v1/accounts/unlock',
  method: 'post',


  headers: headers,
  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`POST /v1/accounts/unlock`


*Unlocks an account(no auth)*


Unlocks an account(no auth)


> Body parameter


```yaml
unlock_token: string


```


<h3 id="postV1AccountsUnlock-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object|false|No description|
|» unlock_token|body|string|true|Token from email|


<h3 id="postV1AccountsUnlock-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Unlocks an account|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Required params are missing|None|
|422|[Unprocessable Entity](https://tools.ietf.org/html/rfc2518#section-10.3)|Validation errors|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## postV1AccountsSendUnlockInstructions


<a id="opIdpostV1AccountsSendUnlockInstructions"></a>


> Code samples


```http
POST //localhost:3000/api/v1/accounts/send_unlock_instructions HTTP/1.1
Host: null
Content-Type: application/x-www-form-urlencoded


```


```shell
# You can also use wget
curl -X POST //localhost:3000/api/v1/accounts/send_unlock_instructions \
  -H 'Content-Type: application/x-www-form-urlencoded'


```


```javascript
var headers = {
  'Content-Type':'application/x-www-form-urlencoded'


};


$.ajax({
  url: '//localhost:3000/api/v1/accounts/send_unlock_instructions',
  method: 'post',


  headers: headers,
  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`POST /v1/accounts/send_unlock_instructions`


*Send unlock instructions*


Send unlock instructions


> Body parameter


```yaml
email: string


```


<h3 id="postV1AccountsSendUnlockInstructions-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|[postV1AccountsSendUnlockInstructions](#schemapostv1accountssendunlockinstructions)|false|No description|
|» email|body|string|true|Account email|


<h3 id="postV1AccountsSendUnlockInstructions-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Send unlock instructions|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## postV1AccountsSendConfirmationInstructions


<a id="opIdpostV1AccountsSendConfirmationInstructions"></a>


> Code samples


```http
POST //localhost:3000/api/v1/accounts/send_confirmation_instructions HTTP/1.1
Host: null
Content-Type: application/x-www-form-urlencoded


```


```shell
# You can also use wget
curl -X POST //localhost:3000/api/v1/accounts/send_confirmation_instructions \
  -H 'Content-Type: application/x-www-form-urlencoded'


```


```javascript
var headers = {
  'Content-Type':'application/x-www-form-urlencoded'


};


$.ajax({
  url: '//localhost:3000/api/v1/accounts/send_confirmation_instructions',
  method: 'post',


  headers: headers,
  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`POST /v1/accounts/send_confirmation_instructions`


*Send confirmations instructions*


Send confirmations instructions


> Body parameter


```yaml
email: string


```


<h3 id="postV1AccountsSendConfirmationInstructions-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|[postV1AccountsSendUnlockInstructions](#schemapostv1accountssendunlockinstructions)|false|No description|
|» email|body|string|true|Account email|


<h3 id="postV1AccountsSendConfirmationInstructions-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Send confirmations instructions|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## postV1AccountsConfirm


<a id="opIdpostV1AccountsConfirm"></a>


> Code samples


```http
POST //localhost:3000/api/v1/accounts/confirm HTTP/1.1
Host: null
Content-Type: application/x-www-form-urlencoded


```


```shell
# You can also use wget
curl -X POST //localhost:3000/api/v1/accounts/confirm \
  -H 'Content-Type: application/x-www-form-urlencoded'


```


```javascript
var headers = {
  'Content-Type':'application/x-www-form-urlencoded'


};


$.ajax({
  url: '//localhost:3000/api/v1/accounts/confirm',
  method: 'post',


  headers: headers,
  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`POST /v1/accounts/confirm`


*Confirms an account(no auth)*


Confirms an account(no auth)


> Body parameter


```yaml
confirmation_token: string


```


<h3 id="postV1AccountsConfirm-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object|false|No description|
|» confirmation_token|body|string|true|Token from email|


<h3 id="postV1AccountsConfirm-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Confirms an account|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Required params are missing|None|
|422|[Unprocessable Entity](https://tools.ietf.org/html/rfc2518#section-10.3)|Validation errors|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## postV1Accounts


<a id="opIdpostV1Accounts"></a>


> Code samples


```http
POST //localhost:3000/api/v1/accounts HTTP/1.1
Host: null
Content-Type: application/x-www-form-urlencoded


```


```shell
# You can also use wget
curl -X POST //localhost:3000/api/v1/accounts \
  -H 'Content-Type: application/x-www-form-urlencoded'


```


```javascript
var headers = {
  'Content-Type':'application/x-www-form-urlencoded'


};


$.ajax({
  url: '//localhost:3000/api/v1/accounts',
  method: 'post',


  headers: headers,
  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`POST /v1/accounts`


*Creates new account(no auth)*


Creates new account(no auth)


> Body parameter


```yaml
email: string
password: string


```


<h3 id="postV1Accounts-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object|false|No description|
|» email|body|string|true|Account Email|
|» password|body|string|true|Account Password|


<h3 id="postV1Accounts-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Creates new account|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Required params are missing|None|
|422|[Unprocessable Entity](https://tools.ietf.org/html/rfc2518#section-10.3)|Validation errors|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## putV1AccountsPassword


<a id="opIdputV1AccountsPassword"></a>


> Code samples


```http
PUT //localhost:3000/api/v1/accounts/password HTTP/1.1
Host: null
Content-Type: application/x-www-form-urlencoded


```


```shell
# You can also use wget
curl -X PUT //localhost:3000/api/v1/accounts/password \
  -H 'Content-Type: application/x-www-form-urlencoded'


```


```javascript
var headers = {
  'Content-Type':'application/x-www-form-urlencoded'


};


$.ajax({
  url: '//localhost:3000/api/v1/accounts/password',
  method: 'put',


  headers: headers,
  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`PUT /v1/accounts/password`


*Change account password*


Change account password


> Body parameter


```yaml
old_password: string
new_password: string


```


<h3 id="putV1AccountsPassword-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object|false|No description|
|» old_password|body|string|true|No description|
|» new_password|body|string|true|No description|


<h3 id="putV1AccountsPassword-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Change account password|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Required params are missing|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Invalid password or bearer token|None|
|422|[Unprocessable Entity](https://tools.ietf.org/html/rfc2518#section-10.3)|Validation errors|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## getV1AccountsMe


<a id="opIdgetV1AccountsMe"></a>


> Code samples


```http
GET //localhost:3000/api/v1/accounts/me HTTP/1.1
Host: null


```


```shell
# You can also use wget
curl -X GET //localhost:3000/api/v1/accounts/me


```


```javascript


$.ajax({
  url: '//localhost:3000/api/v1/accounts/me',
  method: 'get',


  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`GET /v1/accounts/me`


*Return information about current resource owner*


Return information about current resource owner


<h3 id="getV1AccountsMe-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Return information about current resource owner|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Invalid bearer token|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


<h1 id="Barong-profiles">profiles</h1>


Operations about profiles


## postV1Profiles


<a id="opIdpostV1Profiles"></a>


> Code samples


```http
POST //localhost:3000/api/v1/profiles HTTP/1.1
Host: null
Content-Type: application/x-www-form-urlencoded


```


```shell
# You can also use wget
curl -X POST //localhost:3000/api/v1/profiles \
  -H 'Content-Type: application/x-www-form-urlencoded'


```


```javascript
var headers = {
  'Content-Type':'application/x-www-form-urlencoded'


};


$.ajax({
  url: '//localhost:3000/api/v1/profiles',
  method: 'post',


  headers: headers,
  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`POST /v1/profiles`


*Create a profile for current_account*


Create a profile for current_account


> Body parameter


```yaml
first_name: string
last_name: string
dob: '2018-07-13'
address: string
postcode: string
city: string
country: string


```


<h3 id="postV1Profiles-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object|false|No description|
|» first_name|body|string|true|No description|
|» last_name|body|string|true|No description|
|» dob|body|string(date)|true|No description|
|» address|body|string|true|No description|
|» postcode|body|string|true|No description|
|» city|body|string|true|No description|
|» country|body|string|true|No description|


<h3 id="postV1Profiles-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Create a profile for current_account|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Required params are empty|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Invalid bearer token|None|
|409|[Conflict](https://tools.ietf.org/html/rfc7231#section-6.5.8)|Profile already exists|None|
|422|[Unprocessable Entity](https://tools.ietf.org/html/rfc2518#section-10.3)|Validation errors|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## getV1ProfilesMe


<a id="opIdgetV1ProfilesMe"></a>


> Code samples


```http
GET //localhost:3000/api/v1/profiles/me HTTP/1.1
Host: null


```


```shell
# You can also use wget
curl -X GET //localhost:3000/api/v1/profiles/me


```


```javascript


$.ajax({
  url: '//localhost:3000/api/v1/profiles/me',
  method: 'get',


  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`GET /v1/profiles/me`


*Return profile of current resource owner*


Return profile of current resource owner


<h3 id="getV1ProfilesMe-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Return profile of current resource owner|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Invalid bearer token|None|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Account has no profile|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


<h1 id="Barong-security">security</h1>


Operations about securities


## postV1SecurityVerifyApiKey


<a id="opIdpostV1SecurityVerifyApiKey"></a>


> Code samples


```http
POST //localhost:3000/api/v1/security/verify_api_key HTTP/1.1
Host: null
Content-Type: application/x-www-form-urlencoded


```


```shell
# You can also use wget
curl -X POST //localhost:3000/api/v1/security/verify_api_key \
  -H 'Content-Type: application/x-www-form-urlencoded'


```


```javascript
var headers = {
  'Content-Type':'application/x-www-form-urlencoded'


};


$.ajax({
  url: '//localhost:3000/api/v1/security/verify_api_key',
  method: 'post',


  headers: headers,
  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`POST /v1/security/verify_api_key`


*Verify API key*


Verify API key


> Body parameter


```yaml
uid: string
account_uid: string


```


<h3 id="postV1SecurityVerifyApiKey-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object|false|No description|
|» uid|body|string|true|API Key uid|
|» account_uid|body|string|false|Account uid|


<h3 id="postV1SecurityVerifyApiKey-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|API key is valid|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Required params are empty|None|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Record is not found|None|
|422|[Unprocessable Entity](https://tools.ietf.org/html/rfc2518#section-10.3)|Validation errors|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## putV1SecurityResetPassword


<a id="opIdputV1SecurityResetPassword"></a>


> Code samples


```http
PUT //localhost:3000/api/v1/security/reset_password HTTP/1.1
Host: null
Content-Type: application/x-www-form-urlencoded


```


```shell
# You can also use wget
curl -X PUT //localhost:3000/api/v1/security/reset_password \
  -H 'Content-Type: application/x-www-form-urlencoded'


```


```javascript
var headers = {
  'Content-Type':'application/x-www-form-urlencoded'


};


$.ajax({
  url: '//localhost:3000/api/v1/security/reset_password',
  method: 'put',


  headers: headers,
  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`PUT /v1/security/reset_password`


*Sets new account password(no auth)*


Sets new account password(no auth)


> Body parameter


```yaml
reset_password_token: string
password: string


```


<h3 id="putV1SecurityResetPassword-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object|false|No description|
|» reset_password_token|body|string|true|Token from email|
|» password|body|string|true|Account password|


<h3 id="putV1SecurityResetPassword-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Sets new account password(no auth)|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Required params are empty|None|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Record is not found|None|
|422|[Unprocessable Entity](https://tools.ietf.org/html/rfc2518#section-10.3)|Validation errors|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## postV1SecurityResetPassword


<a id="opIdpostV1SecurityResetPassword"></a>


> Code samples


```http
POST //localhost:3000/api/v1/security/reset_password HTTP/1.1
Host: null
Content-Type: application/x-www-form-urlencoded


```


```shell
# You can also use wget
curl -X POST //localhost:3000/api/v1/security/reset_password \
  -H 'Content-Type: application/x-www-form-urlencoded'


```


```javascript
var headers = {
  'Content-Type':'application/x-www-form-urlencoded'


};


$.ajax({
  url: '//localhost:3000/api/v1/security/reset_password',
  method: 'post',


  headers: headers,
  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`POST /v1/security/reset_password`


*Send reset password instructions(no auth)*


Send reset password instructions(no auth)


> Body parameter


```yaml
email: string


```


<h3 id="postV1SecurityResetPassword-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object|false|No description|
|» email|body|string|true|account email|


<h3 id="postV1SecurityResetPassword-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Send reset password instructions(no auth)|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Email is missing|None|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Record is not found|None|
|422|[Unprocessable Entity](https://tools.ietf.org/html/rfc2518#section-10.3)|Validation errors|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## postV1SecurityVerifyCode


<a id="opIdpostV1SecurityVerifyCode"></a>


> Code samples


```http
POST //localhost:3000/api/v1/security/verify_code HTTP/1.1
Host: null
Content-Type: application/x-www-form-urlencoded


```


```shell
# You can also use wget
curl -X POST //localhost:3000/api/v1/security/verify_code \
  -H 'Content-Type: application/x-www-form-urlencoded'


```


```javascript
var headers = {
  'Content-Type':'application/x-www-form-urlencoded'


};


$.ajax({
  url: '//localhost:3000/api/v1/security/verify_code',
  method: 'post',


  headers: headers,
  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`POST /v1/security/verify_code`


*Verify 2FA code*


Verify 2FA code


> Body parameter


```yaml
code: string


```


<h3 id="postV1SecurityVerifyCode-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|[postV1SecurityVerifyCode](#schemapostv1securityverifycode)|false|No description|
|» code|body|string|true|Code from Google Authenticator|


<h3 id="postV1SecurityVerifyCode-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Verify 2FA code|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|2FA has not been enabled for this account or code is missing|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Invalid bearer token|None|
|422|[Unprocessable Entity](https://tools.ietf.org/html/rfc2518#section-10.3)|Validation errors|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## postV1SecurityEnable2fa


<a id="opIdpostV1SecurityEnable2fa"></a>


> Code samples


```http
POST //localhost:3000/api/v1/security/enable_2fa HTTP/1.1
Host: null
Content-Type: application/x-www-form-urlencoded


```


```shell
# You can also use wget
curl -X POST //localhost:3000/api/v1/security/enable_2fa \
  -H 'Content-Type: application/x-www-form-urlencoded'


```


```javascript
var headers = {
  'Content-Type':'application/x-www-form-urlencoded'


};


$.ajax({
  url: '//localhost:3000/api/v1/security/enable_2fa',
  method: 'post',


  headers: headers,
  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`POST /v1/security/enable_2fa`


*Enable 2FA*


Enable 2FA


> Body parameter


```yaml
code: string


```


<h3 id="postV1SecurityEnable2fa-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|[postV1SecurityVerifyCode](#schemapostv1securityverifycode)|false|No description|
|» code|body|string|true|Code from Google Authenticator|


<h3 id="postV1SecurityEnable2fa-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Enable 2FA|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|2FA has been enabled for this account or code is missing|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Invalid bearer token|None|
|422|[Unprocessable Entity](https://tools.ietf.org/html/rfc2518#section-10.3)|Validation errors|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## postV1SecurityGenerateQrcode


<a id="opIdpostV1SecurityGenerateQrcode"></a>


> Code samples


```http
POST //localhost:3000/api/v1/security/generate_qrcode HTTP/1.1
Host: null


```


```shell
# You can also use wget
curl -X POST //localhost:3000/api/v1/security/generate_qrcode


```


```javascript


$.ajax({
  url: '//localhost:3000/api/v1/security/generate_qrcode',
  method: 'post',


  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`POST /v1/security/generate_qrcode`


*Generate qr code for 2FA*


Generate qr code for 2FA


<h3 id="postV1SecurityGenerateQrcode-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Generate qr code for 2FA|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|2FA has been enabled for this account|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Invalid bearer token|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## postV1SecurityRenew


<a id="opIdpostV1SecurityRenew"></a>


> Code samples


```http
POST //localhost:3000/api/v1/security/renew HTTP/1.1
Host: null
Content-Type: application/x-www-form-urlencoded


```


```shell
# You can also use wget
curl -X POST //localhost:3000/api/v1/security/renew \
  -H 'Content-Type: application/x-www-form-urlencoded'


```


```javascript
var headers = {
  'Content-Type':'application/x-www-form-urlencoded'


};


$.ajax({
  url: '//localhost:3000/api/v1/security/renew',
  method: 'post',


  headers: headers,
  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`POST /v1/security/renew`


*Renews JWT if current JWT is valid*


Renews JWT if current JWT is valid


> Body parameter


```yaml
expires_in: string


```


<h3 id="postV1SecurityRenew-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object|false|No description|
|» expires_in|body|string|false|Expires in time in seconds|


<h3 id="postV1SecurityRenew-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Renews JWT if current JWT is valid|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Invalid bearer token|None|
|422|[Unprocessable Entity](https://tools.ietf.org/html/rfc2518#section-10.3)|Invalid expires_in|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


<h1 id="Barong-documents">documents</h1>


Operations about documents


## postV1Documents


<a id="opIdpostV1Documents"></a>


> Code samples


```http
POST //localhost:3000/api/v1/documents HTTP/1.1
Host: null
Content-Type: application/x-www-form-urlencoded


```


```shell
# You can also use wget
curl -X POST //localhost:3000/api/v1/documents \
  -H 'Content-Type: application/x-www-form-urlencoded'


```


```javascript
var headers = {
  'Content-Type':'application/x-www-form-urlencoded'


};


$.ajax({
  url: '//localhost:3000/api/v1/documents',
  method: 'post',


  headers: headers,
  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`POST /v1/documents`


*Upload a new document for current user*


Upload a new document for current user


> Body parameter


```yaml
doc_expire: '2018-07-13'
doc_type: string
doc_number: string
upload: string


```


<h3 id="postV1Documents-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object|false|No description|
|» doc_expire|body|string(date)|true|Document expiration date|
|» doc_type|body|string|true|Document type|
|» doc_number|body|string|true|Document number|
|» upload|body|string(binary)|true|Uploaded file|


<h3 id="postV1Documents-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Document is uploaded|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Required params are empty|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Invalid bearer token|None|
|422|[Unprocessable Entity](https://tools.ietf.org/html/rfc2518#section-10.3)|Validation errors|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## getV1Documents


<a id="opIdgetV1Documents"></a>


> Code samples


```http
GET //localhost:3000/api/v1/documents HTTP/1.1
Host: null


```


```shell
# You can also use wget
curl -X GET //localhost:3000/api/v1/documents


```


```javascript


$.ajax({
  url: '//localhost:3000/api/v1/documents',
  method: 'get',


  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`GET /v1/documents`


*Return current user documents list*


Return current user documents list


<h3 id="getV1Documents-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Return current user documents list|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Invalid bearer token|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


<h1 id="Barong-phones">phones</h1>


Operations about phones


## postV1PhonesVerify


<a id="opIdpostV1PhonesVerify"></a>


> Code samples


```http
POST //localhost:3000/api/v1/phones/verify HTTP/1.1
Host: null
Content-Type: application/x-www-form-urlencoded


```


```shell
# You can also use wget
curl -X POST //localhost:3000/api/v1/phones/verify \
  -H 'Content-Type: application/x-www-form-urlencoded'


```


```javascript
var headers = {
  'Content-Type':'application/x-www-form-urlencoded'


};


$.ajax({
  url: '//localhost:3000/api/v1/phones/verify',
  method: 'post',


  headers: headers,
  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`POST /v1/phones/verify`


*Verify a phone*


Verify a phone


> Body parameter


```yaml
phone_number: string
verification_code: string


```


<h3 id="postV1PhonesVerify-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object|false|No description|
|» phone_number|body|string|true|Phone number with country code|
|» verification_code|body|string|true|Verification code from sms|


<h3 id="postV1PhonesVerify-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Verify a phone|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Required params are empty|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Invalid bearer token|None|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Record is not found|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## postV1PhonesSendCode


<a id="opIdpostV1PhonesSendCode"></a>


> Code samples


```http
POST //localhost:3000/api/v1/phones/send_code HTTP/1.1
Host: null
Content-Type: application/x-www-form-urlencoded


```


```shell
# You can also use wget
curl -X POST //localhost:3000/api/v1/phones/send_code \
  -H 'Content-Type: application/x-www-form-urlencoded'


```


```javascript
var headers = {
  'Content-Type':'application/x-www-form-urlencoded'


};


$.ajax({
  url: '//localhost:3000/api/v1/phones/send_code',
  method: 'post',


  headers: headers,
  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`POST /v1/phones/send_code`


*Resend activation code*


Resend activation code


> Body parameter


```yaml
phone_number: string


```


<h3 id="postV1PhonesSendCode-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|[postV1PhonesSendCode](#schemapostv1phonessendcode)|false|No description|
|» phone_number|body|string|true|Phone number with country code|


<h3 id="postV1PhonesSendCode-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Resend activation code|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Required params are empty|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Invalid bearer token|None|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Record is not found|None|
|422|[Unprocessable Entity](https://tools.ietf.org/html/rfc2518#section-10.3)|Validation errors|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## postV1Phones


<a id="opIdpostV1Phones"></a>


> Code samples


```http
POST //localhost:3000/api/v1/phones HTTP/1.1
Host: null
Content-Type: application/x-www-form-urlencoded


```


```shell
# You can also use wget
curl -X POST //localhost:3000/api/v1/phones \
  -H 'Content-Type: application/x-www-form-urlencoded'


```


```javascript
var headers = {
  'Content-Type':'application/x-www-form-urlencoded'


};


$.ajax({
  url: '//localhost:3000/api/v1/phones',
  method: 'post',


  headers: headers,
  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`POST /v1/phones`


*Add new phone*


Add new phone


> Body parameter


```yaml
phone_number: string


```


<h3 id="postV1Phones-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|[postV1PhonesSendCode](#schemapostv1phonessendcode)|false|No description|
|» phone_number|body|string|true|Phone number with country code|


<h3 id="postV1Phones-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Add new phone|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Required params are empty|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Invalid bearer token|None|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Record is not found|None|
|422|[Unprocessable Entity](https://tools.ietf.org/html/rfc2518#section-10.3)|Validation errors|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


<h1 id="Barong-sessions">sessions</h1>


Operations about sessions


## postV1SessionsGenerateJwt


<a id="opIdpostV1SessionsGenerateJwt"></a>


> Code samples


```http
POST //localhost:3000/api/v1/sessions/generate_jwt HTTP/1.1
Host: null
Content-Type: application/x-www-form-urlencoded


```


```shell
# You can also use wget
curl -X POST //localhost:3000/api/v1/sessions/generate_jwt \
  -H 'Content-Type: application/x-www-form-urlencoded'


```


```javascript
var headers = {
  'Content-Type':'application/x-www-form-urlencoded'


};


$.ajax({
  url: '//localhost:3000/api/v1/sessions/generate_jwt',
  method: 'post',


  headers: headers,
  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`POST /v1/sessions/generate_jwt`


*Validates client jwt and generates peatio session jwt*


Validates client jwt and generates peatio session jwt


> Body parameter


```yaml
kid: string
jwt_token: string


```


<h3 id="postV1SessionsGenerateJwt-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object|false|No description|
|» kid|body|string|true|API Key uid|
|» jwt_token|body|string|true|No description|


<h3 id="postV1SessionsGenerateJwt-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Session is generated|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Required params are empty|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|JWT is invalid|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## postV1Sessions


<a id="opIdpostV1Sessions"></a>


> Code samples


```http
POST //localhost:3000/api/v1/sessions HTTP/1.1
Host: null
Content-Type: application/x-www-form-urlencoded


```


```shell
# You can also use wget
curl -X POST //localhost:3000/api/v1/sessions \
  -H 'Content-Type: application/x-www-form-urlencoded'


```


```javascript
var headers = {
  'Content-Type':'application/x-www-form-urlencoded'


};


$.ajax({
  url: '//localhost:3000/api/v1/sessions',
  method: 'post',


  headers: headers,
  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`POST /v1/sessions`


*Start a new session*


Start a new session


> Body parameter


```yaml
email: string
password: string
application_id: string
expires_in: string
otp_code: string


```


<h3 id="postV1Sessions-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object|false|No description|
|» email|body|string|true|No description|
|» password|body|string|true|No description|
|» application_id|body|string|true|No description|
|» expires_in|body|string|false|No description|
|» otp_code|body|string|false|Code from Google Authenticator|


<h3 id="postV1Sessions-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Start a new session|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Required params are empty|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Invalid bearer token|None|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Record is not found|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


<h1 id="Barong-labels">labels</h1>


Operations about labels


## deleteV1LabelsKey


<a id="opIddeleteV1LabelsKey"></a>


> Code samples


```http
DELETE //localhost:3000/api/v1/labels/{key} HTTP/1.1
Host: null


```


```shell
# You can also use wget
curl -X DELETE //localhost:3000/api/v1/labels/{key}


```


```javascript


$.ajax({
  url: '//localhost:3000/api/v1/labels/{key}',
  method: 'delete',


  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`DELETE /v1/labels/{key}`


*Delete a label  with 'public' scope.*


Delete a label  with 'public' scope.


<h3 id="deleteV1LabelsKey-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|key|path|string|true|Label key.|


<h3 id="deleteV1LabelsKey-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|204|[No Content](https://tools.ietf.org/html/rfc7231#section-6.3.5)|Succefully deleted|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Required params are empty|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Invalid bearer token|None|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Record is not found|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## patchV1LabelsKey


<a id="opIdpatchV1LabelsKey"></a>


> Code samples


```http
PATCH //localhost:3000/api/v1/labels/{key} HTTP/1.1
Host: null
Content-Type: application/x-www-form-urlencoded


```


```shell
# You can also use wget
curl -X PATCH //localhost:3000/api/v1/labels/{key} \
  -H 'Content-Type: application/x-www-form-urlencoded'


```


```javascript
var headers = {
  'Content-Type':'application/x-www-form-urlencoded'


};


$.ajax({
  url: '//localhost:3000/api/v1/labels/{key}',
  method: 'patch',


  headers: headers,
  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`PATCH /v1/labels/{key}`


*Update a label with 'public' scope.*


Update a label with 'public' scope.


> Body parameter


```yaml
value: string


```


<h3 id="patchV1LabelsKey-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|key|path|string|true|Label key.|
|body|body|object|false|No description|
|» value|body|string|true|Label value.|


<h3 id="patchV1LabelsKey-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Update a label with 'public' scope.|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Required params are empty|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Invalid bearer token|None|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Record is not found|None|
|422|[Unprocessable Entity](https://tools.ietf.org/html/rfc2518#section-10.3)|Validation errors|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## getV1LabelsKey


<a id="opIdgetV1LabelsKey"></a>


> Code samples


```http
GET //localhost:3000/api/v1/labels/{key} HTTP/1.1
Host: null


```


```shell
# You can also use wget
curl -X GET //localhost:3000/api/v1/labels/{key}


```


```javascript


$.ajax({
  url: '//localhost:3000/api/v1/labels/{key}',
  method: 'get',


  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`GET /v1/labels/{key}`


*Return a label by key.*


Return a label by key.


<h3 id="getV1LabelsKey-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|key|path|string|true|Label key.|


<h3 id="getV1LabelsKey-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Return a label by key.|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Required params are empty|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Invalid bearer token|None|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Record is not found|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## postV1Labels


<a id="opIdpostV1Labels"></a>


> Code samples


```http
POST //localhost:3000/api/v1/labels HTTP/1.1
Host: null
Content-Type: application/x-www-form-urlencoded


```


```shell
# You can also use wget
curl -X POST //localhost:3000/api/v1/labels \
  -H 'Content-Type: application/x-www-form-urlencoded'


```


```javascript
var headers = {
  'Content-Type':'application/x-www-form-urlencoded'


};


$.ajax({
  url: '//localhost:3000/api/v1/labels',
  method: 'post',


  headers: headers,
  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`POST /v1/labels`


*Create a label with 'public' scope.*


Create a label with 'public' scope.


> Body parameter


```yaml
key: string
value: string


```


<h3 id="postV1Labels-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object|false|No description|
|» key|body|string|true|Label key.|
|» value|body|string|true|Label value.|


<h3 id="postV1Labels-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Create a label with 'public' scope.|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Required params are empty|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Invalid bearer token|None|
|422|[Unprocessable Entity](https://tools.ietf.org/html/rfc2518#section-10.3)|Validation errors|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## getV1Labels


<a id="opIdgetV1Labels"></a>


> Code samples


```http
GET //localhost:3000/api/v1/labels HTTP/1.1
Host: null


```


```shell
# You can also use wget
curl -X GET //localhost:3000/api/v1/labels


```


```javascript


$.ajax({
  url: '//localhost:3000/api/v1/labels',
  method: 'get',


  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`GET /v1/labels`


*List all labels for current account.*


List all labels for current account.


<h3 id="getV1Labels-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|List all labels for current account.|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Invalid bearer token|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


<h1 id="Barong-api_keys">api_keys</h1>


Operations about api_keys


## deleteV1ApiKeysUid


<a id="opIddeleteV1ApiKeysUid"></a>


> Code samples


```http
DELETE //localhost:3000/api/v1/api_keys/{uid}?totp_code=string HTTP/1.1
Host: null


```


```shell
# You can also use wget
curl -X DELETE //localhost:3000/api/v1/api_keys/{uid}?totp_code=string


```


```javascript


$.ajax({
  url: '//localhost:3000/api/v1/api_keys/{uid}',
  method: 'delete',
  data: '?totp_code=string',


  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`DELETE /v1/api_keys/{uid}`


*Delete an api key*


Delete an api key


<h3 id="deleteV1ApiKeysUid-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|uid|path|string|true|No description|
|totp_code|query|string|true|Code from Google Authenticator|


<h3 id="deleteV1ApiKeysUid-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|204|[No Content](https://tools.ietf.org/html/rfc7231#section-6.3.5)|Succefully deleted|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Required params are empty|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Invalid bearer token|None|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Record is not found|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## patchV1ApiKeysUid


<a id="opIdpatchV1ApiKeysUid"></a>


> Code samples


```http
PATCH //localhost:3000/api/v1/api_keys/{uid} HTTP/1.1
Host: null
Content-Type: application/x-www-form-urlencoded


```


```shell
# You can also use wget
curl -X PATCH //localhost:3000/api/v1/api_keys/{uid} \
  -H 'Content-Type: application/x-www-form-urlencoded'


```


```javascript
var headers = {
  'Content-Type':'application/x-www-form-urlencoded'


};


$.ajax({
  url: '//localhost:3000/api/v1/api_keys/{uid}',
  method: 'patch',


  headers: headers,
  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`PATCH /v1/api_keys/{uid}`


*Updates an api key*


Updates an api key


> Body parameter


```yaml
public_key: string
scopes: string
expires_in: string
state: string
totp_code: string


```


<h3 id="patchV1ApiKeysUid-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|uid|path|string|true|No description|
|body|body|object|false|No description|
|» public_key|body|string|false|No description|
|» scopes|body|string|false|comma separated scopes|
|» expires_in|body|string|false|expires_in duration in seconds|
|» state|body|string|false|State of API Key. "active" state means key is active and can be used for auth|
|» totp_code|body|string|true|Code from Google Authenticator|


<h3 id="patchV1ApiKeysUid-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Updates an api key|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Required params are empty|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Invalid bearer token|None|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Record is not found|None|
|422|[Unprocessable Entity](https://tools.ietf.org/html/rfc2518#section-10.3)|Validation errors|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## getV1ApiKeysUid


<a id="opIdgetV1ApiKeysUid"></a>


> Code samples


```http
GET //localhost:3000/api/v1/api_keys/{uid}?totp_code=string HTTP/1.1
Host: null


```


```shell
# You can also use wget
curl -X GET //localhost:3000/api/v1/api_keys/{uid}?totp_code=string


```


```javascript


$.ajax({
  url: '//localhost:3000/api/v1/api_keys/{uid}',
  method: 'get',
  data: '?totp_code=string',


  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`GET /v1/api_keys/{uid}`


*Return an api key by uid*


Return an api key by uid


<h3 id="getV1ApiKeysUid-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|uid|path|string|true|No description|
|totp_code|query|string|true|Code from Google Authenticator|


<h3 id="getV1ApiKeysUid-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Return an api key by uid|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Required params are empty|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Invalid bearer token|None|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Record is not found|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## postV1ApiKeys


<a id="opIdpostV1ApiKeys"></a>


> Code samples


```http
POST //localhost:3000/api/v1/api_keys HTTP/1.1
Host: null
Content-Type: application/x-www-form-urlencoded


```


```shell
# You can also use wget
curl -X POST //localhost:3000/api/v1/api_keys \
  -H 'Content-Type: application/x-www-form-urlencoded'


```


```javascript
var headers = {
  'Content-Type':'application/x-www-form-urlencoded'


};


$.ajax({
  url: '//localhost:3000/api/v1/api_keys',
  method: 'post',


  headers: headers,
  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`POST /v1/api_keys`


*Create an api key*


Create an api key


> Body parameter


```yaml
public_key: string
scopes: string
expires_in: string
totp_code: string


```


<h3 id="postV1ApiKeys-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object|false|No description|
|» public_key|body|string|true|No description|
|» scopes|body|string|false|comma separated scopes|
|» expires_in|body|string|false|expires_in duration in seconds|
|» totp_code|body|string|true|Code from Google Authenticator|


<h3 id="postV1ApiKeys-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Create an api key|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Required params are empty|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Invalid bearer token|None|
|422|[Unprocessable Entity](https://tools.ietf.org/html/rfc2518#section-10.3)|Validation errors|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


## getV1ApiKeys


<a id="opIdgetV1ApiKeys"></a>


> Code samples


```http
GET //localhost:3000/api/v1/api_keys?totp_code=string HTTP/1.1
Host: null


```


```shell
# You can also use wget
curl -X GET //localhost:3000/api/v1/api_keys?totp_code=string


```


```javascript


$.ajax({
  url: '//localhost:3000/api/v1/api_keys',
  method: 'get',
  data: '?totp_code=string',


  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`GET /v1/api_keys`


*List all api keys for current account.*


List all api keys for current account.


<h3 id="getV1ApiKeys-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|totp_code|query|string|true|Code from Google Authenticator|


<h3 id="getV1ApiKeys-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|List all api keys for current account.|None|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Require 2FA and totp code|None|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Invalid bearer token|None|


<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
BearerToken
</aside>


# Schemas


<h2 id="tocSlabel">Label</h2>


<a id="schemalabel"></a>


```json
{
  "key": "string",
  "value": "string",
  "scope": "string",
  "created_at": "string",
  "updated_at": "string"
}
```


### Properties


|Name|Type|Required|Description|
|---|---|---|---|
|key|string|false|Label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters.|
|value|string|false|Label value. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters.|
|scope|string|false|Label scope: 'public' or 'private'|
|created_at|string|false|No description|
|updated_at|string|false|No description|


<h2 id="tocSapikey">APIKey</h2>


<a id="schemaapikey"></a>


```json
{
  "uid": "string",
  "public_key": "string",
  "scopes": "string",
  "expires_in": "string",
  "state": "string",
  "created_at": "string",
  "updated_at": "string"
}
```


### Properties


|Name|Type|Required|Description|
|---|---|---|---|
|uid|string|false|No description|
|public_key|string|false|No description|
|scopes|string|false|comma separated scopes|
|expires_in|string|false|expires_in duration in seconds. Min 30 seconds, Max 86400 seconds|
|state|string|false|No description|
|created_at|string|false|No description|
|updated_at|string|false|No description|


<script type="application/ld+json">
{
  "@context": "http://schema.org/",
  "@type": "WebAPI",
  "description": "API for barong OAuth server ",


  "name": "Barong"
}
</script>


