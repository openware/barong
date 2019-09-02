# frozen_string_literal:true

require 'barong/app'

# Store sessions in cookies

Rails.application.config.session_store :cookie_store, key: '_barong_session'
Barong::App.set(:session_expire_time, '1800', type: :integer)
