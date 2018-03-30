# Generating credentials for client app

1. Edit `config/seed.yml`

|                 |                        |
|-----------------|------------------------|
| oauth_app_name | Name of the client app  |
| oauth_callback_url | When access is granted, this URL will be triggered with the parameter :code appended. |

2. Run `bundle exec rake db:seed` to create Admin user and Client application
3. Using your Admin email and password sign in to Barong
4. You can find your Clien App credentials in Applications tab on admin panel

**NOTICE:** Application generated with `bundle exec rake db:seed` won't ask for client app authorization.
