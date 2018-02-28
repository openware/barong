---
title: Barong v0.0.1
language_tabs:
  - shell: Shell
  - http: HTTP
  - javascript: JavaScript
  - javascript--nodejs: Node.JS
  - ruby: Ruby
  - python: Python
  - java: Java
toc_footers: []
includes: []
search: true
highlight_theme: darkula
headingLevel: 2


---


<h1 id="Barong">Barong v0.0.1</h1>


> Scroll down for code samples, example requests and responses. Select a language for code samples from the tabs above or the mobile navigation menu.


API for barong OAuth server 


Base URLs:


* <a href="//localhost:3000/api">//localhost:3000/api</a>


<h1 id="Barong-account">account</h1>


Operations about accounts


## getAccount


<a id="opIdgetAccount"></a>


> Code samples


```shell
# You can also use wget
curl -X GET //localhost:3000/api/account


```


```http
GET //localhost:3000/api/account HTTP/1.1
Host: null


```


```javascript


$.ajax({
  url: '//localhost:3000/api/account',
  method: 'get',


  success: function(data) {
    console.log(JSON.stringify(data));
  }
})


```


```javascript--nodejs
const request = require('node-fetch');


fetch('//localhost:3000/api/account',
{
  method: 'GET'


})
.then(function(res) {
    return res.json();
}).then(function(body) {
    console.log(body);
});


```


```ruby
require 'rest-client'
require 'json'


result = RestClient.get '//localhost:3000/api/account',
  params: {
  }


p JSON.parse(result)


```


```python
import requests


r = requests.get('//localhost:3000/api/account', params={


)


print r.json()


```


```java
URL obj = new URL("//localhost:3000/api/account");
HttpURLConnection con = (HttpURLConnection) obj.openConnection();
con.setRequestMethod("GET");
int responseCode = con.getResponseCode();
BufferedReader in = new BufferedReader(
    new InputStreamReader(con.getInputStream()));
String inputLine;
StringBuffer response = new StringBuffer();
while ((inputLine = in.readLine()) != null) {
    response.append(inputLine);
}
in.close();
System.out.println(response.toString());


```


`GET /account`


*Return information about current resource owner*


Return information about current resource owner


<h3 id="getAccount-responses">Responses</h3>


|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Return information about current resource owner|None|


<aside class="success">
This operation does not require authentication
</aside>


