# Service Accounts
Service account is an account on the platform that belongs to User.

User cannot create a Service account, but it can be created via Management API. There is no possibility to login into Service Account, but you can use it via API Keys.

User has an ability to list Service Accounts, that belongs to him. Also User can create, update, delete and list API Keys for these Service Accounts using his own OTP.

Service Account will have the same level and as User, to which it belongs, but the role can be any.

If User disable OTP, all API Keys for his Service Accounts becomes inactive.

If User state changes, his Service Accounts also changes the state.
