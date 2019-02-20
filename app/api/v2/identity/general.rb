# frozen_string_literal: true

module API::V2
  module Identity
    class General < Grape::API
      desc 'Test connectivity'
      get '/ping' do
        { ping: 'pong' }
      end

      desc 'Get server current unix timestamp.'
      get '/time' do
        ts = ::Time.now.to_i
        { time: ts }
      end
    end
  end
end
