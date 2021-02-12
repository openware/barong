# frozen_string_literal: true

module API::V2
  module Public
    class General < Grape::API

      desc 'KYC callback'
      post '/kyc' do
        return_status = KycService.kycaid_callback(params)
        status return_status
      end

      desc 'Password strength testing'
      params do
        requires :password, type: String, desc: 'User password'
      end
      post '/password/validate' do
        { entropy: PasswordStrengthChecker.calculate_entropy(params[:password]) }
      end

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
          phone_verification_type: Barong::App.config.phone_verification,
          password_min_entropy: Barong::App.config.password_min_entropy,
          password_regexp: Barong::App.config.password_regexp
        }.compact
      end

      desc 'Get auth0 configuration'
      get '/configs/auth0' do
        {
          auth0_domain: Barong::App.config.auth0_domain,
          auth0_client_id: Barong::App.config.auth0_client_id
        }.compact
      end
    end
  end
end
