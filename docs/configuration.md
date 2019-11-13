
# Barong Configuration
## Twilio configuration
For twilio configuration we need to set such required envs
- `BARONG_TWILIO_ACCOUNT_SID`, which acts as a twilio username
- `BARONG_TWILIO_SERVICE_SID`, which acts as a twilio password
- `BARONG_TWILIO_PHONE_NUMBER`, virtual phone numbers which will give you instant access to local, national, mobile, and toll-free phone numbers

We have ability to set twilio with 3 different ways
1. ```BARONG_PHONE_VERIFICATION == "twilio_sms"```
     If you choose phone verification as twilio sms we will use send_sms [API call](https://www.twilio.com/docs/sms/send-messages)
       Also you can add your own template for sms using `BARONG_SMS_CONTENT_TEMPLATE`
2. ```BARONG_PHONE_VERIFICATION == "twilio_verify"```
     In this case we will use twilio Verify [API call](https://www.twilio.com/docs/verify/api)
     There are a lot of benefits of using Verify API like you can validate users via voice
     One verification service can be used to send multiple verification tokens, it is not necessary to create a new service each time, so you can set ```BARONG_TWILIO_SERVICE_SID``` at once
3. ```BARONG_PHONE_VERIFICATION == "mock"```
     With this type of verification all the numbers will be accepted and validated as a right code for any given number

---
## Storage configuration
1. Google
For Google storage configuration you need fill  ENV variables below
- `PROVIDER: "Google"`
- `GOOGLE_STORAGE_ACCESS_KEY_ID`
- `GOOGLE_STORAGE_SECRET_ACESS_KEY`
  [Learn more about creating Access/Secret keys](https://bitmovin.zendesk.com/hc/en-us/articles/360001017393-How-can-I-create-Access-Secret-keys-for-Google-Cloud-Storage-)
2. AWS
For AWS storage configuration you need fill ENV variables below
- `PROVIDER: "AWS"`

- `AWS_SIGNATURE_VERSION`

- `AWS_ACCESS_KEY_ID`

- `AWS_SECRET_ACCESS_KEY`

- `REGION`

- `ENDPOINT`

- `PATH_STYLE`

  [Learn more about how to find Access/Secret keys](https://help.bittitan.com/hc/en-us/articles/115008255268-How-do-I-find-my-AWS-Access-Key-and-Secret-Access-Key-)
3. AliCloud
For AliCloud storage configuration you need fill ENV variables below
- `PROVIDER`
- `ALIYUN_ACCESSKEY_ID`
- `ALIYUN_ACCESSKEY_SECRET`
- `ALIYUN_OSS_BUCKET`
- `ALIYUN_REGION_ID`
- `ALIYUN_OSS_ENDPOINT`

  [Learn more about how to create Access key](https://www.alibabacloud.com/help/doc-detail/53045.htm)

---



## Recaptcha configuration

reCAPTCHA is a CAPTCHA-like system designed to establish that a computer user is human (normally in order to protect websites from bots) and, at the same time, assist in the digitization of books or improve machine learning. 

You can learn more about how to create ``RECAPTCHA_SECRET_KEY``, ``RECAPTCHA_SITE_KEY`` in this [article](https://writeup.xyz/how-to/google-recaptcha-v2-tutorial-3125/)

---

## Blacklist/Whitelist configuration

`Pass` routes will never be checked by AuthZ endpoint and will be available without session requirement. On `Block` routes user always will get 401, it doesn't depend on a session / role / ip / etc

You need to put whitelisted (public) routes for pass object and blacklisted routes for block in authz_rules.yml

```yml
rules:
  pass:
  	- api/v2/barong/identity
  	- api/v2/peatio/public
  	- api/v2/ranger/public
  	- api/v2/applogic/public
   block:
  	- api/v2/barong/management
  	- api/v2/peatio/managemen
```

---

## State configuration

We can customize barong configuration as we want

1. For user activation we just need to have verified email label in example below. You can put  more labels to create your own rules for user activation
2. For example, if you want to ban your user you just need to put ban and fraud labels on tower admin panel. For sure you can customize this case too and put change or add label names in barong.yml
3. For document verification we use, as standard - following document types. But you can configure available document types by changing or extending existing list. This way we keep an opportunity to support any custom KYC services, logic, etc

```yml
activation_requirements:
  email: 'verified'
state_triggers:
  banned:
    - ban
    - fraud
  deleted:
    - delete
  locked:
    - suspicious
    - lock
document_types:
  - Passport
  - Identity card
  - Driver license
  - Utility Bill
  - Residental
  - Institutional
```

