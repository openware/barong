# Barong KYCAID configuration
In Barong 2.5 and higher you can use the external KyC provider (KYCAID)[https://www.kycaid.com/] to fully automated your KYC process.

### Basic configuration
Barong now support 2 ways of managing KYC - `local` and `kycaid`. You can switch between them using `BARONG_KYC_PROVIDER` env. By default this ENV has `kycaid`, as a value. If you set `local`as a value, then legacy flow will be turned on. `Profile` and `Document` steps will require manual admin approve from tower.

### Credentials configuration
Once every credential is setted up correctly `KYCAID` will work in Barong out of the box. Lets see what we need to set up to make it work properly:

1) We need to set up a bucket for storing docs (docs submitted by user will be stored both in barong and on KYCAID side)
Basic creds needed for that should be set in envs: `barong_storage_provider`, `barong_storage_bucket_name`, `barong_storage_access_key`, `barong_storage_secret_key`. 
More about available options read here: [Barong storage configuration](https://www.openware.com/sdk/docs/barong/configuration.html#storage-configuration)
2) We need to set up authorization creds for KYCAID (get one on official site https://www.kycaid.com/). ENVs for that available under namings: 
`barong_kycaid_authorization_token` - for auth secret token, 
`barong_kycaid_sandbox_mode` - for switching between test mode and prod mode (`true` by default),
`barong_kycaid_form_id` - the form unique identificator. Used for inheritance of form configuration like ACR and email templates
3) Be sure to check if `barong_domain` ENV has a correct value including `https:` at the beginning. This ENV configures the `callback` url, so its improtant.
4) Be sure to check `BARONG_REQUIRED_DOCS_EXPIRE` ENV value to be `false` if you want to include `address` verification in your KYC process. You can set it to `true` if only document check needed.
5) Check if in the `authz_rules.yml` file you have permitted path `- api/v2/barong/public` in the `pass` module. This allows platform to receive `callback`, as it is in the public module
6) Check if in the `barong.yml` file you have correct list of `document_types`. Be sure, that you have at least this values inside:
  - Passport
  - Identity card
  - Driver license
  - Address

### Sidekiq
Dont forget to check if your deployment / local installation has running sidekiq. As soon as all the jobs are running a-sync, we use sidekiq to interact with `KYCAID` in order to make user verification fast and clear from user point of view.

Sidekiq runs with a command `bundle exec sidekiq` with the same image and ENVs as barong.

### Verification flow explanation
First 2 common steps of KYC remains unchanged. We still use internal email verification and phone verification using Twilio.
#### Profile step
After user has submitted profile - we send a request to KYCAID, registering this user in KYCAID database and creating a n `applicant` record for him. At this step no additional checks provided by KYCAID team.

#### Document step
User can submit docs (2 or 3), depending on the type he choose. It can be `passport`, it can be `driver license`, etc.
User need to provide photo of `first page` of document, `second page` if needed and `SELFIE`.
After user has submitted all the docs, we send them to the `bucket`, configured by platform (to save them internally and show on `tower`) and also send files to `KYCAID`, downloading them to `KYCAID database`. 

After that Barong triggers `verification request` with 2 types - `DOCUMENT` check and `FACIAL` check. From this moment verifications and checks are performing on `KYCAID` side (check their site and contact support to find out more about `algorithms` here https://www.kycaid.com/). KYCAID team sends back a `callback` with decision.
In our system, both `FACIAL` and `DOCUMENT` resolutes to one label, with key = `document`, so if one of those verifications fails - end user will get `reject` on his verification `attempt`.
If verification decision is `approve` user will automatically get updated label to `verified` and corresponding level.

#### Address step
Address step implemented pretty the same, as previous, document one. User sumbits document, that proves his residence.
After user has submitted all the docs, we send them to the `bucket`, configured by platform (to save them internally and show on `tower`) and also send files to `KYCAID`, downloading them to `KYCAID database`. 
After that Barong triggers `verification request` with only 1 type - `ADDRESS`. After all verification process on the `KYCAID` side `BARONG` receives callback with decision. If its positive - user get his level and `address`:`verified` label.
