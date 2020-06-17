# frozen_string_literal: true

require 'spec_helper'

describe API::V2::Public::General do
  describe 'GET /api/v2/public/time' do
    it 'returns a server status' do
      get '/api/v2/public/ping'
      expect_status_to_eq(200)
      expect(json_body[:ping]).to eq('pong')
    end
  end

  describe 'GET /api/v2/public/time' do
    it 'returns a current UNIX time' do
      get '/api/v2/public/time'
      expect_status_to_eq(200)
      expect(json_body[:time].to_i).to be <= Time.now.to_i
    end
  end

  describe 'GET /api/v2/public/configs' do
    it 'returns some of the configurations' do
      get '/api/v2/public/configs'
      expect_status_to_eq(200)
      expect(json_body[:session_expire_time]).to eq(Barong::App.config.session_expire_time)
      expect(json_body[:captcha_type]).to eq(Barong::App.config.captcha)
      expect(json_body[:phone_verification_type]).to eq(Barong::App.config.phone_verification)
    end

    it 'returns all of the configurations with defaults' do
      get '/api/v2/public/configs'
      expect_status_to_eq(200)
      expect(json_body[:session_expire_time]).to eq(Barong::App.config.session_expire_time)
      expect(json_body[:captcha_type]).to eq(Barong::App.config.captcha)
      expect(json_body[:phone_verification_type]).to eq(Barong::App.config.phone_verification)
      expect(json_body[:password_min_entropy]).to eq(Barong::App.config.password_min_entropy)
      expect(json_body[:password_regexp]).to eq(Barong::App.config.password_regexp.to_s)
    end
  end
end
