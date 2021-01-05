# Run the barong mailer locally

## Prerequisites
You need to following deamons running

1. RabbitMQ
2. Redis

## Start Rails console

```bash
rails console
```

## Start the mailer

1. Generate the barong public key in base64 format

```
cat config/rsa-key.pub | base64 -w0 (base64 -b0 for MacOS users)
```

2. Configure it in config/mailer.yml
Replace *changeme* with the previous generated string.

```yaml
 keychain:
   barong:
     algorithm: RS256
     value: "changeme"
```

## Generate an event

From the rails console you can generate an event by creating a label on a user:

```ruby
Label.create!(user_id:1, key: 'phone', value: 'verified')
```
