# Troubleshooting
## Permissions
- `401 authz.invalid_permission` on specific endpoint
1. Check list of your permissions on barong seeds.yml or tower admin panel
2. If there are no such permission just add new permission on tower admin panel

- `401 authz.invalid_permission` after login
1. Check your permissions on barong rails console
```ruby
irb(main)013:0> Permission.all
irb(main)013:0> Rails.cache.read('permissions')
```
2. If there are no permissions on rails cache or these permissions are wrong you need to run following command
When you delete permissions from rails cache they will be automatically fetched
```ruby
irb(main)013:0> Rails.cache.delete('permissions')
```
3. If there are no permissions on DB you need to seed permissions
```
bundle exec rake db:seed
```
***
## Restictions
*Be careful with testing restriction and don't ban your local IP!*