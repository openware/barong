# Barong Security Hardening
This document describes the available security options implemented in the application and advices for configuring with highlighting the main (high-risk) security options

### Password hashing
Barong since 2.0 version use OpenBSD bcrypt() password hashing algorithm, that allow us easily store a secure hash of users' passwords.

As a base Barong takes [bcrypt-ruby gem](https://github.com/codahale/bcrypt-ruby) - Ruby binding for the OpenBSD bcrypt() With [rails 5 has_secure_password](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html) it gives us full power of algorithm.

Read more about [password hashing algorithm in barong](https://www.openware.com/sdk/docs/barong/general/password-hashing.html).

Read more about additional [password strength and regexp configuration](https://www.openware.com/sdk/docs/barong/configuration.html#password-configuration).

### Challenge–response test (captcha protection)

In order to prevent script attacks on API and possible brute force on session- and user- related endpoints we implement captcha protection.

Configuration manages through environment variable - BARONG_CAPTCHA. Available values - geetest, recaptcha, none. With a wrong value barong will fail on start with error: `#{KEY}` invalid, enabled values: `NONE GEETEST RECAPTCHA`.

!!NOTE: `NONE` is a default value, but its highly not recommended to use in `production` environment.

List of endpoints protected can be configured in `barong.yml` file, common (and the most secure) list of endpoints is:
```
captcha_protected_endpoints:
  - user_create
  - session_create
  - password_reset
  - email_confirmation
 ```

Captcha will be verified on `SERVER` side. All requests without captcha will be denied with `error` `captcha_response.missing`

More about captcha you can read here [captcha policy documentation](https://www.openware.com/sdk/docs/barong/general/captcha.html).

### CSRF protection
`Cross-Site Request Forgery` (`CSRF`) is an attack that forces an end user to execute unwanted actions on a web application in which they’re currently authenticated. CSRF attacks specifically target state-changing requests, not theft of data since the attacker has no way to see the response to the forged request.
`CSRF` has become a huge deal in the recent years and it’s a part of `OWASP` top 10 common vulnerabilities

There are some common practices to protect your website.

First of all only `POST, PUT, PATCH, DELETE` and `TRACE` HTML requests have to be protected, since only these methods are destructive and can cause any unwanted or unauthorized damage.
Therefore, every time we sent such a request we need to append a specific token to it, to verify that request is sent from a legit HTML form. The token has to be included in `X-CSRF-Token` (commonly used one).

This is the flow we went for:
1. On session creation backend sends a unique crypto-function generated token
2. Frontend stores that token in the DOM, typically it’s in the meta tag.
3. Every time a destructive request is sent to the backend, this token is appended in the header
4. Backend validates the header and performs the action. Error is returned if the header is invalid.
5. When the session is destroyed, the token is also destroyed and can’t be used again.

This approach is called a per-session token method.

For further information check the links down below:
* https://www.owasp.org/index.php/Main_Page
* https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html#javascript-guidance-for-auto-inclusion-of-csrf-tokens-as-an-ajax-request-header
* https://www.owasp.org/index.php/Category:OWASP_Top_Ten_Project
