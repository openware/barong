# frozen_string_literal: true

module Barong
  class RedisSession
    def self.hexdigest_session(session_id)
      Digest::SHA256.hexdigest(session_id.to_s)
    end

    # We have session stored in redis
    # Like _session_id:2::value
    def self.encrypted_session(session_id)
      "_session_id:2::#{hexdigest_session(session_id)}"
    end

    def self.add(user_uid, session_id, expire_time)
      key = key_name(user_uid, session_id)
      Rails.cache.fetch(key, expires_in: expire_time) {
        encrypted_session(session_id)
      }
    end

    def self.delete(user_uid, session_id)
      key = key_name(user_uid, session_id)
      Rails.cache.delete(key)
    end

    def self.update(user_uid, session_id, expire_time)
      key = key_name(user_uid, session_id)
      value = encrypted_session(session_id)
      Rails.cache.write(key, value, expires_in: expire_time)
    end

    def self.invalidate_all(user_uid, session_id = nil)
      # Get list of active user sessions
      session_keys = Rails.cache.redis.keys("#{user_uid}_session_*")

      # Delete user sessions from native session list
      # If session ID present
      # system should invalidate all session except this session ID
      key_name = key_name(user_uid, session_id)
      session_keys.delete_if {|s_key| s_key == key_name }.each do |key|
        # Read value from additional redis list
        value = Rails.cache.read(key)
        # Delete session from native redis list
        Rails.cache.delete(value)
      end

      # Delete list of all user sessions from additinal redis list
      session_keys.each do |key|
        Rails.cache.delete(key)
      end
    end

    def self.key_name(user_uid, session_id)
      if session_id.present?
        hsid = hexdigest_session(session_id)
        "#{user_uid}_session_#{hsid}"
      end
    end
  end
end
