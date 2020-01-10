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

      desc 'Get barong version'
      get '/version' do
        {
          git_tag: Barong::Application::GIT_TAG,
          git_sha: Barong::Application::GIT_SHA,
          build_date: DateTime.rfc3339(Barong::Application::BUILD_DATE),
          version: Barong::Application::VERSION
        }
      end

      desc 'Get barong configurations'
      get '/configs' do
        {
          session_expire_time: Barong::App.config.session_expire_time,
          captcha_type: Barong::App.config.captcha,
          captcha_id: (Barong::App.config.recaptcha_site_key if Barong::App.config.captcha == 'recaptcha'),
          phone_verification_type: Barong::App.config.phone_verification
        }.compact
      end
    end
  end
end
