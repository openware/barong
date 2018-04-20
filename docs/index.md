---
title: Barong v1.7.0
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


<h1 id="Barong">Barong v1.7.0</h1>


> Scroll down for code samples, example requests and responses. Select a language for code samples from the tabs above or the mobile navigation menu.


API for barong OAuth server


Base URLs:


* <a href="//localhost:3000/api">//localhost:3000/api</a>


<h1 id="Barong-accounts">accounts</h1>


Operations about accounts


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


*Creates new account*


Creates new account


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


<aside class="success">
This operation does not require authentication
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


*Change user's password*


Change user's password


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
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Change user's password|None|


<aside class="success">
This operation does not require authentication
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


<aside class="success">
This operation does not require authentication
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
dob: '2018-04-20'
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


<aside class="success">
This operation does not require authentication
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


<aside class="success">
This operation does not require authentication
</aside>


<h1 id="Barong-security">security</h1>


Operations about securities


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


*Sets new account password*


Sets new account password


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
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Sets new account password|None|


<aside class="success">
This operation does not require authentication
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


*Send reset password instructions*


Send reset password instructions


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
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Send reset password instructions|None|


<aside class="success">
This operation does not require authentication
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


<aside class="success">
This operation does not require authentication
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


<aside class="success">
This operation does not require authentication
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


<aside class="success">
This operation does not require authentication
</aside>


## postV1SecurityRenew


<a id="opIdpostV1SecurityRenew"></a>


> Code samples


```http
POST //localhost:3000/api/v1/security/renew HTTP/1.1
Host: null


```


```shell
# You can also use wget
curl -X POST //localhost:3000/api/v1/security/renew


```


```javascript


$.ajax({
  url: '//localhost:3000/api/v1/security/renew',
  method: 'post',


  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


`POST /v1/security/renew`


*Renews JWT if current JWT is valid*


Renews JWT if current JWT is valid


<h3 id="postV1SecurityRenew-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Renews JWT if current JWT is valid|None|


<aside class="success">
This operation does not require authentication
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
doc_expire: string
doc_type: string
doc_number: string
upload: string


```


<h3 id="postV1Documents-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object|false|No description|
|» doc_expire|body|string|true|No description|
|» doc_type|body|string|true|No description|
|» doc_number|body|string|true|No description|
|» upload|body|string|true|No description|


<h3 id="postV1Documents-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Upload a new document for current user|None|


<aside class="success">
This operation does not require authentication
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


<aside class="success">
This operation does not require authentication
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


<aside class="success">
This operation does not require authentication
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
|body|body|object|false|No description|
|» phone_number|body|string|true|Phone number with country code|


<h3 id="postV1Phones-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Add new phone|None|


<aside class="success">
This operation does not require authentication
</aside>


<h1 id="Barong-sessions">sessions</h1>


Operations about sessions


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


```


<h3 id="postV1Sessions-parameters">Parameters</h3>


|Parameter|In|Type|Required|Description|
|---|---|---|---|---|
|body|body|object|false|No description|
|» email|body|string|true|No description|
|» password|body|string|true|No description|
|» application_id|body|string|true|No description|
|» expires_in|body|string|false|No description|


<h3 id="postV1Sessions-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|201|[Created](https://tools.ietf.org/html/rfc7231#section-6.3.2)|Start a new session|None|


<aside class="success">
This operation does not require authentication
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
|204|[No Content](https://tools.ietf.org/html/rfc7231#section-6.3.5)|Delete a label  with 'public' scope.|None|


<aside class="success">
This operation does not require authentication
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


<aside class="success">
This operation does not require authentication
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


<aside class="success">
This operation does not require authentication
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


<aside class="success">
This operation does not require authentication
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


<aside class="success">
This operation does not require authentication
</aside>


<script type="application/ld+json">
{
  "@context": "http://schema.org/",
  "@type": "WebAPI",
  "description": "API for barong OAuth server ",


  "name": "Barong"
}
</script>
