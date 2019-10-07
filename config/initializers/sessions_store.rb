# frozen_string_literal:true

# Store sessions in cache
Rails.application.config.session_store :cache_store, key: '_barong_session', expire_after: 24.hours.seconds
