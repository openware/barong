# frozen_string_literal: true

# Use cache_store as session_store for Rails sessions. Key default is '_barong_session'
Rails.application.config.session_store :cache_store, key: Barong::App.config.session_name, expire_after: 24.hours.seconds
