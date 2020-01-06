# Barong Captcha Policy
#### Overview
A CAPTCHA (an acronym for "Completely Automated Public Turing test to tell Computers and Humans Apart") is a type of challenge–response test used in computing to determine whether or not the user is human) [Link to wiki](https://en.wikipedia.org/wiki/CAPTCHA)

Currently Barong versions 2.3+ supports 3 options in captcha policy on `sign up` and `sign in` API endpoints.

Configuration manages through environment variable - `BARONG_CAPTCHA`. Available values - `geetest`, `recaptcha`, `none`.
With a wrong value barong will fail on start with error: `#{KEY} invalid, enabled values: NONE GEETEST RECAPTCHA`.

## Disabled (default)
`none` - if ENV `BARONG_CAPTCHA` has this value - no captcha response will be required on sign in and sign up, so no bot traffic prevention.
This option is not recommended to use in `production` environment.
`None` policy was designed in testing and demo purposes, to start barong without any additional keys.

## Re CAPTCHA v2
reCAPTCHA is a free service that protects your site from spam and abuse. It uses advanced risk analysis techniques to tell humans and bots apart. [Get started from google team](https://developers.google.com/recaptcha/intro)

`recaptcha` - this value in `BARONG_CAPTCHA` env enables re_captcha protection, designed and maintained by Google company. [Small developers tips from google team](https://developers.google.com/recaptcha/docs/display)

To properly configurate re_captcha you will need to set value for ENVs `recaptcha_site_key` and `recaptcha_secret_key`. Both of them you can generate [in google admin panel](https://www.google.com/recaptcha/admin/create)

After enabling and configuring captcha, `sign up` and `sign in` endpoint will require new parameter - `captcha_response`(`string`) and validate captcha response on server side, to protect from bots traffic.

## Geetest Captcha (Puzzle captcha)

GeeTest captcha is an user-friendly captcha with high security. GeeTest captcha enables digital businesses to secure control of their websites against bots. [geetest captcha site](https://www.geetest.com)

`geetest` - this value in BARONG_CAPTCHA env enables geetest captcha protection, designed and maintained by geetest.com

To properly configurate `geetest` you will need to set value for ENVs `geetest_id` and `geetest_key`. How to generate them, you can find in official [get started guide](https://docs.geetest.com/captcha/overview/guide)

After enabling and configuring geetest captcha, `sign up` and `sign in` endpoint will require new parameter - `captcha_response`(`hash` - with three keys `geetest_challenge`, `geetest_seccode`, `geetest_validate`) and validate captcha response on server side, to protect from bots traffic.
