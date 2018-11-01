# frozen_string_literal: true

require 'spec_helper'

describe API::V2::Identity::General do
  describe 'GET /api/v2/time' do
    it 'returns a server status' do
      get '/api/v2/ping'
      expect_status_to_eq(200)
      expect(json_body[:ping]).to eq('pong')
    end
  end

  describe 'GET /api/v2/time' do
    it 'returns a current UNIX time' do
      get '/api/v2/time'
      expect_status_to_eq(200)
      expect(json_body[:time].to_i).to be <= Time.now.to_i
    end
  end
end
