## How to import users and referrals to Barong database

1. Create `csv` file for users and referrals with template.

### Users table

  |      uid      | email           | level |    role      |  state  | referral_uid  |
  |---------------|-----------------|-------|--------------|---------|---------------|
  | ID1000003837  | admin@barong.io |   3   | superadmin   | active  | ID1000003828  |

  uid, email - require params

2. For import users
   
```ruby
   bundle exec rake import:users['file_name.csv']
```

3. For import referrals

```ruby
  bundle exec rake import:referrals['file_name.csv']
```
