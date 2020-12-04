### Activities

To track admin activities you need to define it on seed.yml on `permissions` key
- `role` should be in a range of existing: `admin`, `superadmin`, `support`, `techical`, `accountant`
- `verb` should be `post`, `get`, `put`, `delete`
- `path` - endpoint which should be checked, should be started with `api/v2/#{component}` as prefix
- `action` should be `audit`
```
For example

permissions:
- { role: 'admin', verb: 'post', path: api/v2/admin, action: audit }
```

Here you can see a list of possible fields for activity:
|   Field    |   Type   | Description |
|:-----------|:--------:|:-----------:|
| user_id    | bigint   | ID of user who creates activity |
| target_uid | string   | User UID for whom activity was created (admin remove OTP for user, target_uid will be uid of user for which admin removed OTP|
| category   | string   | `admin` (admin activities), `user` (user activities)|
| user_ip    | string   | IP address |
| user_agent | string   | User Agent such as `Mozilla/5.0`|
| topic      | string   | Defined topic (`session`, `adjustments`) or `general` by default|
| action     | string   | API action: `POST => 'create'`, `PUT => 'update'`, `GET => 'read'`, `DELETE => 'delete'`, `PATCH => 'update'` or `system` if there is no match of HTTP method|
| result     | string   | Status of API response: `succeed`, `failed`, `denied`|
| data       | text     | Parameters which was sent to specific API endpoint|
| created_at | datetime | Time of activity creation|

##### Useful commands
If you want to delete old activities you can run next command

Be sure that your parameters has valid date string, such as `YYYY-mm-dd` !
```
bundle exec rake activities:delete[from,to]
```
