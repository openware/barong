# Service Accounts
In Barong a service account belongs to a user.

Service accounts are currently created only via Management API (server to server API).
There is no possibility to login into service account, it's used through API using an API Key.

User has an ability to list his service accounts. Also User can create, update, delete and list API Keys for these service accounts using his own OTP.

A user service account has the same level as the user, the role can be different.

If User disable OTP, all API Keys for his service accounts will become inactive.

If a user state changes, his service accounts state will change accordingly.
