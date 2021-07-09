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
## CORS

1. After setting up CORS Barong envs make sure to configure envoy.
Configuration example can be found on the [opendax documentation](https://github.com/openware/opendax/#using-an-opendax-deployment-for-local-frontend-development).

2. For kubernetes cluster: if you can see that `access-control-allow-origin` or other cors headers are differ from what you set up in Barong envs - it can be caused by ingress controller which overwrites your cors settings. Check [this documentation](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#enable-cors) and edit envoy ingress controller.
***
## Restictions
*Be careful with testing restriction and don't ban your local IP!*