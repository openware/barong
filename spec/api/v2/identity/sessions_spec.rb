# frozen_string_literal: true

describe API::V2::Identity::Sessions do
  include_context 'geoip mock'

  include ActiveSupport::Testing::TimeHelpers
  let!(:create_member_permission) do
    create :permission,
           role: 'member',
           verb: 'all'
  end
  before do
    Rails.cache.delete('permissions')
    allow(Barong::App.config).to receive_messages(captcha: 'recaptcha')
  end

  describe 'POST /api/v2/identity/sessions' do
    before { allow(Barong::App.config).to receive_messages(captcha: 'none') }

    let!(:email) { 'user@gmail.com' }
    let!(:password) { 'testPassword111' }
    let(:uri) { '/api/v2/identity/sessions' }
    subject!(:user) do
      create :user,
            :with_profile,
             email: email,
             password: password,
             password_confirmation: password
    end
    let(:otp_enabled) { false }

    context 'With valid params' do
      let(:do_request) { post uri, params: params }
      let(:session_expire_time) do
        Barong::App.config.session_expire_time
      end
      let(:check_session) do
        get '/api/v2/auth/api/v2/tasty_endpoint'
      end
      let(:params) do
        {
          email: email,
          password: password
        }
      end

      context 'captcha behaviour when captcha policy is recaptcha' do
        before { allow(Barong::App.config).to receive_messages(captcha: 'recaptcha') }

        it 'doesnt require captcha if endpoint is not in the protection list' do
          allow(BarongConfig).to receive(:list).and_return({"captcha_protected_endpoints"=>["user_create"]})
          do_request

          expect_status_to_eq 200
          result = JSON.parse(response.body)
          expect(result['profiles'][0]['last_name']).to eq user.profiles.first.sub_masked_last_name
          expect(result['profiles'][0]['dob']).to eq user.profiles.first.sub_masked_dob
        end

        it 'require captcha if endpoint is in the protection list' do
          allow(BarongConfig).to receive(:list).and_return({"captcha_protected_endpoints"=>["user_create", "session_create"]})

          do_request
          expect_status_to_eq 400
          expect_body.to eq(errors: ["identity.captcha.required"])
        end
      end

      it 'Check current credentials and returns session' do
        do_request

        expect(session.instance_variable_get(:@delegate)[:uid]).to eq(user.uid)
        expect_status.to eq(200)
        result = JSON.parse(response.body)
        expect(result['profiles'][0]['last_name']).to eq user.profiles.first.sub_masked_last_name
        expect(result['profiles'][0]['dob']).to eq user.profiles.first.sub_masked_dob

        check_session
        expect(response.status).to eq(200)
      end

      it 'Expires a session after configured time' do
        do_request
        travel session_expire_time + 30.minutes
        check_session
        expect(response.status).to eq(401)
      end

      let(:captcha_response) { nil }
      let(:valid_response) { 'valid' }
      let(:invalid_response) { 'invalid' }

      before do
        allow_any_instance_of(CaptchaService::RecaptchaVerifier).to receive(:verify_recaptcha)
          .with(model: user,
                skip_remote_ip: true,
                response: valid_response) { true }

        allow_any_instance_of(CaptchaService::RecaptchaVerifier).to receive(:verify_recaptcha)
          .with(model: user,
                skip_remote_ip: true,
                response: invalid_response) { raise StandardError }
      end

      context 'when captcha response is blank' do
        let(:params) do
          {
            email: email,
            password: password,
            captcha_response: captcha_response
          }
        end
      end

      context 'when captcha response is not valid' do
        let(:params) do
          {
            email: email,
            password: password,
            captcha_response: invalid_response
          }
        end

        before do
          expect_any_instance_of(CaptchaService::RecaptchaVerifier).to receive(:verify_recaptcha) { false }
        end

        it 'renders an error' do
          allow(Barong::App.config).to receive_messages(captcha: 'recaptcha')
          do_request
          expect(json_body[:errors]).to eq(["identity.captcha.verification_failed"])
          expect_status_to_eq 422
        end
      end

      context 'when captcha response is valid' do
        let(:params) do
          {
            email: email,
            password: password,
            captcha_response: valid_response
          }
        end

        before do
          expect_any_instance_of(CaptchaService::RecaptchaVerifier).to receive(:verify_recaptcha) { true }
        end
      end
    end

    context 'With Invalid params' do
      context 'Checks current credentials and returns error' do
        it 'when email, password is missing' do
          post uri
          expect_body.to eq(errors: ["identity.session.missing_email", "identity.session.missing_password"])
          expect(response.status).to eq(422)
        end

        it 'when password is missing' do
          post uri, params: { email: email }
          expect_body.to eq(errors: ["identity.session.missing_password"])
          expect(response.status).to eq(422)
        end

        context 'when Password is wrong' do
          it 'returns errror' do
            post uri, params: { email: email, password: 'password' }
            expect_body.to eq(errors: ["identity.session.invalid_params"])
            expect(response.status).to eq(401)
          end
        end
      end
    end

    context 'User state related errors' do
      context 'When user is banned' do
        let!(:banned_email) { 'email@random.com' }
        let!(:user_banned) do
          create :user,
                 email: banned_email,
                 password: password,
                 password_confirmation: password,
                 state: 'banned'
        end

        it 'returns error on banned user' do
          post uri, params: { email: banned_email, password: password }
          expect_body.to eq(errors: ["identity.session.banned"])
          expect(response.status).to eq(401)
        end
      end

      let!(:pending_email) { 'pendingemail@random.com' }
      let!(:user_pending) do
        create :user,
               email: pending_email,
               password: password,
               password_confirmation: password,
               state: 'pending'
      end

      context 'Allow pending user to login by default' do
        it 'returns error on non-active user' do
          user_pending.update(state: 'not-active')
          post uri, params: { email: pending_email, password: password }
          expect_body.to eq(errors: ["identity.session.not_active"])
          expect(response.status).to eq(401)
        end

        it 'sucessfull login for pending user' do
          user_pending.update(state: 'pending')
          expect(user_pending.state).to eq('pending')

          post uri, params: { email: pending_email, password: password }
          expect(response.status).to eq(200)
        end
      end
    end

    context 'event API behavior' do
      before do
        allow(EventAPI).to receive(:notify)
      end

      it 'receive system.session.create notify' do
        allow_any_instance_of(API::V2::Utils).to receive(:remote_ip).and_return('192.168.0.1')
        post uri, params: { email: email, password: password }, headers: { 'HTTP_USER_AGENT' => 'random-browser' }

        expect(EventAPI).to have_received(:notify).with('system.session.create',
          hash_including({ record: hash_including(user: anything, user_ip: '192.168.0.1', user_agent: 'random-browser') })
        )
      end
    end
  end

  describe 'DELETE /api/v2/identity/sessions' do
    before { allow(Barong::App.config).to receive_messages(captcha: 'none') }

    let!(:email) { 'user@gmail.com' }
    let!(:password) { 'testPassword111' }
    let(:uri) { '/api/v2/identity/sessions' }
    let(:params) do
      {
        email: email,
        password: password
      }
    end
    subject!(:user) do
      create :user,
             email: email,
             password: password,
             password_confirmation: password
    end

    context 'With invalid session' do
      let(:do_create_session_request) { post uri, params: params }
      let(:do_delete_session_request) { delete uri }


      it 'receives 404 on delete session' do
        do_delete_session_request
        expect(response.status).to eq(404)
        expect(response.body).to eq("{\"errors\":[\"identity.session.not_found\"]}")
      end
    end

    context 'With valid session' do
      let(:do_create_session_request) { post uri, params: params }
      let(:do_delete_session_request) { delete uri }

      it 'Deletes session' do
        do_create_session_request
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq(user.uid)

        do_delete_session_request
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq(nil)
      end

      it "return invalid set-cookie header on #logout" do
        do_create_session_request
        expect(session.instance_variable_get(:@delegate)[:uid]).to eq(user.uid)

        do_delete_session_request
        expect(response.status).to eq(200)
        expect(response.headers['Set-Cookie']).not_to be_nil
        expect(response.headers['Set-Cookie']).to include "barong_session"
      end
    end
  end

  describe 'POST /api/v2/indentity/sessions/auth0' do
    let(:uri) { '/api/v2/identity/sessions/auth0' }

    context 'user doesnt exist' do
      context 'email verified' do
        let(:payload) do
          [
            {
            'email': 'example@barong.io',
            'email_verified': true,
            'iss': 'https://domain.name/',
            'sub': 'google-oauth2|100484476630231723',
            'aud': 'test audience',
            'iat': Time.now.to_i,
            'exp': (Time.now + 5.minutes).to_i
            }.with_indifferent_access,
            {
              'alg': 'RS256',
              'typ': 'JWT',
              'kid': 'ptd2123vE-G12GoDvJ8MQ'
            }
          ]
        end

        before do
          allow(Barong::Auth0::JWT).to receive(:verify).and_return(payload)
        end

        it 'create user and label' do
          expect(User.find_by(email: 'example@barong.io')).to eq nil
          post uri, params: { id_token: 'TestToken' }

          expect(response.status).to eq(201)
          result = JSON.parse(response.body)
          user = User.find_by(email: result['email'])
          expect(user).not_to be nil
          expect(user.level).to eq 1
          expect(user.state).to eq 'active'
          expect(user.labels.count).to eq 1
          expect(user.labels.find_by(key: 'email').value).to eq 'verified'
        end
      end
    end

    context 'user exists' do
      let(:payload) do
        [
          {
            'email': 'example@barong.io',
            'email_verified': true,
            'iss': 'https://domain.name/',
            'sub': 'google-oauth2|100484476630231723',
            'aud': 'test audience',
            'iat': Time.now.to_i,
            'exp': (Time.now + 5.minutes).to_i
          }.with_indifferent_access,
          {
            'alg': 'RS256',
            'typ': 'JWT',
            'kid': 'ptd2123vE-G12GoDvJ8MQ'
          }
        ]
      end

      before do
        allow(Barong::Auth0::JWT).to receive(:verify).and_return(payload)
      end

      let!(:user) { create(:user, email: 'example@barong.io')}

      it 'returns existing user with session' do
        expect(User.find_by(email: 'example@barong.io')).not_to eq nil
        post uri, params: { id_token: 'TestToken' }

        expect(response.status).to eq(201)
        result = JSON.parse(response.body)
        expect(result['email']).to eq user.email
        expect(result.keys).to match_array(['email','uid','role','level','otp','state','referral_uid','csrf_token','data','labels','phones','profiles','data_storages', 'created_at', 'updated_at', 'username'])
      end
    end

    context 'invalid params' do
      it 'without params' do
        post uri
        expect_body.to eq(errors: ['identity.session.missing_id_token', 'identity.session.empty_id_token'])
        expect(response.status).to eq(422)
      end

      it 'with empty param' do
        post uri, params: { id_token: '' }
        expect_body.to eq(errors: ['identity.session.empty_id_token'])
        expect(response.status).to eq(422)
      end

      context 'jwt expired' do
        before do
          allow(Barong::Auth0::JWT).to receive(:verify).and_raise(JWT::ExpiredSignature)
        end

        it 'raise an error' do
          post uri, params: { id_token: 'TestToken' }
          expect_body.to eq(errors: ['identity.session.auth0.invalid_params'])
          expect(response.status).to eq(422)
        end
      end

      context 'email is not verified' do
        let(:payload) do
          [
            {
            'email': 'example@barong.io',
            'email_verified': false,
            'iss': 'https://domain.name/',
            'sub': 'google-oauth2|100484476630231723',
            'aud': 'test audience',
            'iat': Time.now.to_i,
            'exp': (Time.now + 5.minutes).to_i
            }.with_indifferent_access,
            {
              'alg': 'RS256',
              'typ': 'JWT',
              'kid': 'ptd2123vE-G12GoDvJ8MQ'
            }
          ]
        end

        before do
          allow(Barong::Auth0::JWT).to receive(:verify).and_return(payload)
        end

        it 'doesnt create user and label' do
          expect(User.find_by(email: 'example@barong.io')).to eq nil
          post uri, params: { id_token: 'TestToken' }

          expect(User.find_by(email: 'example@barong.io')).to eq nil
          expect_body.to eq(errors: ['identity.session.auth0.invalid_params'])
          expect(response.status).to eq(401)
        end
      end
    end
  end
end
