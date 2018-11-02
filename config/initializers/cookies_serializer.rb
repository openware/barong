# Be sure to restart your server when you modify this file.

Rails.application.config.action_dispatch.signed_cookie_digest = 'SHA256'

# Specify a serializer for the signed and encrypted cookie jars.
# Valid options are :json, :marshal, and :hybrid.
Rails.application.config.action_dispatch.cookies_serializer = :json
