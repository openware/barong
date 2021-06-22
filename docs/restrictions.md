# Restrictions

### Introduction
First version of restrictions appeared in 2.3 as simple blacklist feature, by IP in several scopes (by `country`, by `continent`, by `ip_subnet` and by `ip`).

Starting from latest 2.4 restrictions will act as system of traffic control. New fields added to restrictions table - `category`, `code`, and new available value for `scope` - `all`

##### Main points: 
Every request to the server will be validated (both `public` and `private` APIs, but not `management` one ). Request IP will match with existing restrictions and a first found rule will be applayed. 
`category` - one of `whitelist`, `maintenance`, `blacklist`, `blocklogin`. 

The order of matching IP with existing rules is strict and cant be changed: 
1. Whitelist ( all -> ip -> ip_subnet -> country -> continent )
2. Maintenance ( all -> ip -> ip_subnet -> country -> continent )
3. Blacklist ( all -> ip -> ip_subnet -> country -> continent )
4. Blocklogin ( all -> ip -> ip_subnet -> country -> continent )

`Whitelist` - rule, that marks IP as trusted, as IP that can have an access to the server APIs
`Maintenance` - when enabled, will return an error - 471 (by default) to any request to server in a range of rules `scope` (Typically, should be used with `all` and in maintenance platform purposes)
`Blacklist` - when enabled, will return an error - `code`, which can be customized by the rule. Code can be different for different `scopes`, and can be used to display different error or kind alert of UI. Default `code` for errors `{ continent: 423, country: 423, ip_subnet: 403, ip: 401, all: 401 }`
`Blocklogin` - acts as `Blacklist`, but applies only on `sessions` endpoint.

##### How to configure
Restrictions can be:
1. Seeded via seed feature. 
Just put restrictions in format of   `- { category: whitelist, scope: country, value: UA, state: disabled }` in seed.yml under `restrictions:` module
2. Can be added by admin via `api/v2/barong/admin/restrictions`, 
    requires `:scope`, requires `:value`, requires `:category`, optional `:state, default: 'enabled`', optional `:code `
3. Can be added automatically (whitelist category) via whitelink feature

### Whitelink feature
In order to make the process of whitelisting IPs easier starting from latest 2.4 admin can create a `whitelink_token` via
`api/v2/barong/admin/restrictions/whitelink`. Created token can be sent to `api/v2/barong/identity/users/access` and if it is valid (every token has expiry time, which is 1 day by default) and it will automatically create a `whitelist` restriction with current request IP.
Note: `api/v2/barong/identity/users/access` API available to call even if all other platform traffic is under blacklist or maintenance

### Restrictions Usage
Combining whitelist, maintenance and blacklist rules can help in controlling platform traffic, maintaining platform, developing custom cases and complex UI structure.
##### Several usecases:
##### Maintenance - rules:
`category: 'maintenance', scope: 'all', value: 'all', state: 'enabled', code: 471`
`category: 'whitelist', scope: 'ip_subnet', value: '#{dev_team_office_ip}', state: 'enabled'`

In this case all users, that will try to access any API of the platform will get a responce with status `471` and body `authz.restrict.maintenance`. In this case frontend can show a maintenance page for users, so they will understand that platform is under service right now. Meanwhile, all requests from `#{dev_team_office_ip}` (as they are whitelisted) will still reach server and can test the update / validate any bug found, etc.

##### Blacklisting - rules:
`category: 'blacklist', scope: 'country', value: 'US', state: 'enabled', code: 455`
`category: 'blacklist', scope: 'continent', value: 'NA', state: 'enabled', code: 456`
`category: 'whitelist', scope: 'ip', value: '#{investor_ip}', state: 'enabled'`

In this case all users from North America, that will try to access any API of the platform will get a responce with status `456` and body `authz.restrict.blacklist`. In this case frontend can show a page for users, so they will understand that they cant yet reach this platform from their current location, but it will come soon. All users from USA will have a different code - `455`, so UI can show the page, which will indicates, that platform is banned for USA residents and cant be reached from this country.
Meanwhile, in testing and business purpose you can whitelist one concrete or subset of IPs, for you investors, for lawyers or any demo, using `whitelist` rule.