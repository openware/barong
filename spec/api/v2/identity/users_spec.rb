# frozen_string_literal: true

require 'spec_helper'

describe API::V2::Identity::Users do
  include_context 'geoip mock'

  let!(:create_member_permission) do
    create :permission,
           role: 'member',
           verb: 'all'
    create :permission,
           role: 'member',
           verb: 'all',
           path: 'tasty_endpoint'
  end

  describe 'language behaviour on POST /api/v2/identity/users' do
    let(:do_request) { post '/api/v2/identity/users', params: params }
    let(:params) { { email: 'valid@email.com', password: 'Tecohvi0' } }

    before do
      Rails.cache.delete('permissions')
      allow(EventAPI).to receive(:notify)
    end

    context 'with language parameter' do
      it 'accept UPCASE letters' do
        params[:lang] = 'FR'
        do_request

        expect(EventAPI).to have_received(:notify).with('system.user.email.confirmation.token',
          hash_including({record: hash_including(language: 'FR')})
        )
      end

      it 'accept LOWERCASE letters and transforms to UPCASE letters' do
        params[:lang] = 'fr'
        do_request

        expect(EventAPI).to have_received(:notify).with('system.user.email.confirmation.token',
          hash_including({ record: hash_including(language: 'FR') })
        )
      end
    end

    context 'without language parameter' do
      it 'use default EN if no language provided' do
        do_request

        expect(EventAPI).to have_received(:notify).with('system.user.email.confirmation.token',
          hash_including({ record: hash_including(language: 'EN') })
        )
      end

      it 'use default EN if empty string provided as language' do
        params[:lang] = ''
        do_request

        expect(EventAPI).to have_received(:notify).with('system.user.email.confirmation.token',
          hash_including({ record: hash_including(language: 'EN') })
        )
      end
    end
  end

  describe 'POST /api/v2/identity/users with default Barong::App.config.barong_captcha' do
    let(:do_request) { post '/api/v2/identity/users', params: params }

    context 'when email is invalid' do
      let(:params) { { email: 'bad_format', password: 'Password1' } }

      it 'renders an error' do
        do_request
        expect_status_to_eq 422
        expect_body.to eq(errors: ["email.invalid", "password.password.password_strength"])
      end
    end

    context 'when referral is unexist' do
      let(:params) { { email: 'valid.email@gmail.com', password: 'Password1', refid: 'ID1231231231' } }

      it 'renders an error' do
        do_request
        expect_status_to_eq 422
        expect_body.to eq(errors: ["identity.user.referral_doesnt_exist"])
      end
    end

    context 'when referral id is invalid' do
      let(:params) { { email: 'valid.email@gmail.com', password: 'Password1', refid: 'UID123' } }

      it 'renders an error' do
        do_request
        expect_status_to_eq 422
        expect_body.to eq(errors: ["identity.user.invalid_referral_format"])
      end
    end

    context 'when Password is invalid' do
      let(:params) { { email: 'vadid.email@gmail.com', password: 'password' } }

      it 'renders an error' do
        do_request
        expect_status_to_eq 422
        expect_body.to eq(errors: ["password.requirements", "password.password.password_strength"])
      end
    end

    context 'when email and password are absent' do
      let(:params) {}

      it 'renders an error' do
        do_request
        expect_status_to_eq 422
        expect_body.to eq(errors: ["identity.user.missing_email", "identity.user.empty_email", "identity.user.missing_password", "identity.user.empty_password"])
      end
    end

    context 'when email is blank' do
      let(:params) { { email: '', password: 'zieV0Kai' } }

      it 'renders an error' do
        do_request
        expect_status_to_eq 422
        expect_body.to eq(errors: ["identity.user.empty_email"])
      end
    end

    context 'when email is valid' do
      let(:params) { { email: 'vadid.email@gmail.com', password: 'eeC2BiCucxWEQ' } }

      it 'creates an account' do
        do_request
        expect_status_to_eq 201
      end
    end

    context 'language specified' do
      let(:params) { { email: 'vadid.email@gmail.com', password: 'eeC2BiCucxWEQ', lang: 'ua' } }

      it 'notifies with right language' do
        allow(EventAPI).to receive(:notify)

        do_request

        expect(EventAPI).to have_received(:notify).with('model.user.created', record: hash_including(email: 'vadid.email@gmail.com'))
        expect(EventAPI).to have_received(:notify).with('system.user.email.confirmation.token',
          hash_including({ record: hash_including(language: 'UA') })
        )
      end
    end

    context 'language not specified' do
      let(:params) { { email: 'vadid.email@gmail.com', password: 'eeC2BiCucxWEQ' } }

      it 'notifies with default language' do
        allow(EventAPI).to receive(:notify)

        do_request

        expect(EventAPI).to have_received(:notify).with('model.user.created', hash_including({ record: hash_including(email: 'vadid.email@gmail.com') }))
        expect(EventAPI).to have_received(:notify).with('system.user.email.confirmation.token', hash_including({ record: hash_including(language: 'EN') }))
      end
    end
  end

  describe 'POST /api/v2/identity/users with reCAPTCHA Barong::App.config.barong_captcha' do
    before { allow(Barong::App.config).to receive_messages(barong_captcha: 'recaptcha') }


    let(:do_request_with_captcha) { post '/api/v2/identity/users', params: params_with_captcha }
    let(:params_with_captcha) { { email: 'vadid.email@gmail.com', password: 'eeC2BiCucxWEQ', captcha_response: 'response' } }
    let(:do_request) { post '/api/v2/identity/users', params: params }
    let(:params) { { email: 'vadid.email@gmail.com', password: 'eeC2BiCucxWEQ' } }

    context 'when reCAPTCHA is valid' do

      it 'creates an account' do
        allow_any_instance_of(CaptchaService::RecaptchaVerifier).to receive(:verify_recaptcha) { true }

        do_request_with_captcha
        expect_status_to_eq 201
      end

      it 'doesnt require captcha if endpoint is not in the protection list' do
        allow(BarongConfig).to receive(:list).and_return({"сaptcha_protected_endpoints"=>["session_create"]})

        do_request
        expect_status_to_eq 201
      end

      it 'require captcha if endpoint is in the protection list' do
        allow(BarongConfig).to receive(:list).and_return({"сaptcha_protected_endpoints"=>["user_create", "session_create"]})

        do_request
        expect_status_to_eq 400
        expect_body.to eq(errors: ["identity.captcha.required"])
      end
    end

    context 'when reCAPTCHA is invalid' do
      before { allow_any_instance_of(CaptchaService::RecaptchaVerifier).to receive(:verify_recaptcha) { false } }

      it 'renders an error' do
        do_request_with_captcha
        expect_status_to_eq 422
        expect_body.to eq(errors: ["identity.captcha.verification_failed"])
      end
    end

    context 'when captcha_response is blank but Barong::App.config.barong_captcha requires reCAPTCHA response' do
      let(:params) { { email: 'vadid.email@gmail.com', password: 'eeC2BiCucxWEQ' } }

      it 'renders an error' do
        do_request
        expect_status_to_eq 400
        expect_body.to eq(errors: ["identity.captcha.required"])
      end
    end
  end

  describe 'POST /api/v2/identity/users with GeeTest Barong::App.config.barong_captcha' do
    before { allow(Barong::App.config).to receive_messages(barong_captcha: 'geetest') }

    let(:do_request) { post '/api/v2/identity/users', params: params }
    let(:params) do
      { email: 'vadid.email@gmail.com', password: 'eeC2BiCucxWEQ',
        captcha_response: { geetest_challenge: 'challenge',
                            geetest_validate: 'validate',
                            geetest_seccode: 'seccode' } }
    end

    context 'when GeeTest is valid' do
      before { allow_any_instance_of(CaptchaService::GeetestVerifier).to receive(:validate) { true } }

      it 'creates an account' do
        do_request
        expect_status_to_eq 201
      end
    end

    context 'when GeeTest is invalid' do
      before { allow_any_instance_of(CaptchaService::GeetestVerifier).to receive(:validate) { false } }

      it 'renders an error' do
        do_request
        expect_status_to_eq 422
        expect_body.to eq(errors: ["identity.captcha.verification_failed"])
      end
    end

    context 'when captcha_response is blank but Barong::App.config.barong_captcha requires Geetest response' do
      let(:params) { { email: 'vadid.email@gmail.com', password: 'eeC2BiCucxWEQ' } }

      it 'renders an error' do
        do_request
        expect_status_to_eq 400
        expect_body.to eq(errors: ["identity.captcha.required"])
      end
    end

    context 'when captcha_response has incorrect format' do
      let(:params) do
        { email: 'vadid.email@gmail.com', password: 'eeC2BiCucxWEQ',
          captcha_response: { empty: 'string' } }
      end

      it 'renders an error' do
        do_request
        expect_status_to_eq 400
        expect_body.to eq(errors: ["identity.captcha.mandatory_fields"])
      end
    end
  end

  describe 'POST /api/v2/identity/users with data field' do
    let(:do_request) { post '/api/v2/identity/users', params: params }
    let(:params) do
      { email: 'vadid.email@gmail.com', password: 'eeC2BiCucxWEQ',
        data: data }
    end

    context 'when data is not json compatible' do
      let(:data) { 'phone_number: 380969999999' }

      it 'renders an error' do
        do_request
        expect_status_to_eq 422
        expect_body.to eq(errors: ["data.invalid_format"])
      end
    end

    context 'valid data' do
      let(:data) { "{\"phone_number\":\"380969999999\"}" }

      it 'creates user' do
        do_request
        expect_status_to_eq 201
      end
    end
  end

  describe 'session opening on  /api/v2/identity/users' do
    before do
      Rails.cache.delete('permissions')
    end

    let(:email) { 'valid@email.com' }
    let(:do_request) { post '/api/v2/identity/users', params: params }
    let(:params) { { email: email, password: 'Tecohvi0' } }
    let(:session_expire_time) do
      Barong::App.config.session_expire_time
    end
    let(:check_session) do
      get '/api/v2/auth/tasty_endpoint'
    end

    it 'Check current credentials and returns session' do
      do_request
      user = User.find_by(email: email)

      expect(user).not_to be(nil)
      expect(session.instance_variable_get(:@delegate)[:uid]).to eq(user.uid)
      expect_status.to eq(201)

      check_session
      expect(response.status).to eq(200)
    end
  end

  describe 'POST /api/v2/identity/users/email/generate_code' do
    before { allow(BarongConfig).to receive(:list).and_return({"сaptcha_protected_endpoints"=>["user_create", "session_create"]}) }
    let(:params) { { email: 'invalid@email.com' } }
    let(:do_request) { post '/api/v2/identity/users/email/generate_code', params: params }

    context 'when user is invalid' do
      it 'doesnt render an error to prevent user enumeration' do
        do_request
        expect_status_to_eq 201
      end
    end

    let(:params) { { email: 'valid-confirmed@email.com' } }
    context 'when user is valid, email confirmed' do
      it 'doesnt render an error to prevent user enumeration' do
        create(:user, email: 'valid-confirmed@email.com', state: 'active')
        do_request
        expect_status_to_eq 201
      end
    end

    context 'when user is valid' do
      let(:user) { create(:user, state: 'pending') }
      let(:params) { { email: user.email } }
      it 'returns a success' do
        do_request
        expect_status_to_eq 201
      end
    end

    context 'captcha behaviour when captcha policy is recaptcha' do
      let(:user) { create(:user, state: 'pending') }
      let(:params) { { email: user.email } }
      before { allow(Barong::App.config).to receive_messages(barong_captcha: 'recaptcha') }

      it 'doesnt require captcha if endpoint is not in the protection list' do
        allow(BarongConfig).to receive(:list).and_return({"сaptcha_protected_endpoints"=>["user_create", "session_create"]})

        do_request
        expect_status_to_eq 201
      end

      it 'require captcha if endpoint is in the protection list' do
        allow(BarongConfig).to receive(:list).and_return({"сaptcha_protected_endpoints"=>["user_create", "session_create", "email_confirmation"]})

        do_request
        expect_status_to_eq 400
        expect_body.to eq(errors: ["identity.captcha.required"])
      end
    end
  end

  describe 'session opening on  /api/v2/identity/users/email/confirm_code' do
    before do
      Rails.cache.delete('permissions')
    end

    let(:user) { create(:user, state: 'pending', email: 'valid_email@email.com') }
    let(:do_request) { post '/api/v2/identity/users/email/confirm_code', params: params }
    let(:params) { { token: codec.encode(sub: 'confirmation', email: user.email, uid: user.uid) } }
    let(:session_expire_time) do
      Barong::App.config.session_expire_time
    end
    let(:check_session) do
      get '/api/v2/auth/tasty_endpoint'
    end

    it 'Gives label email verified and opens a session' do
      do_request

      expect(user).not_to be(nil)
      expect(session.instance_variable_get(:@delegate)[:uid]).to eq(user.uid)
      expect_status.to eq(201)

      check_session
      expect(response.status).to eq(200)
    end
  end

  describe 'POST /api/v2/identity/users/email/confirm_code' do
    let(:do_request) { post '/api/v2/identity/users/email/confirm_code', params: params }
    let(:params) { {} }

    context 'when token is missing' do
      it 'returns an error' do
        do_request
        expect_status_to_eq 422
        expect_body.to eq(errors: ["identity.user.missing_token", "identity.user.empty_token"])
      end
    end

    context 'when token is invalid' do
      let(:params) { { token: 'invalid token' } }

      it 'returns an error' do
        do_request
        expect_status_to_eq 403
        expect_body.to eq(errors: ["jwt.decode_and_verify"])
      end
    end

    context 'when token is valid' do
      let(:user) { create(:user, state: 'pending', email: 'valid_email@email.com') }
      let(:params) { { token: codec.encode(sub: 'confirmation', email: user.email, uid: user.uid) } }
      it 'updates state to active' do
        do_request
        expect_status_to_eq 201
      end
    end
  end

  describe 'POST /api/v2/identity/users/password/generate_code' do
    let(:do_request) do
      post '/api/v2/identity/users/password/generate_code', params: params
    end
    let(:params) { { email: email } }

    context 'when email is unknown' do
      let(:email) { 'unknown@gmail.com' }

      it 'renders not found error' do
        do_request
        expect_status_to_eq 404
        expect_body.to eq(errors: ["identity.password.user_doesnt_exist"])
      end
    end

    context 'when user is found by email' do
      let!(:user) { create(:user, email: email) }
      let(:email) { 'email@gmail.com' }

      it 'sends reset password instructions' do
        do_request
        expect_status_to_eq 201
      end
    end

    context 'captcha behaviour when captcha policy is recaptcha' do
      let!(:user) { create(:user, email: email) }
      let(:email) { 'email@gmail.com' }
      before { allow(Barong::App.config).to receive_messages(barong_captcha: 'recaptcha') }

      it 'doesnt require captcha if endpoint is not in the protection list' do
        allow(BarongConfig).to receive(:list).and_return({"сaptcha_protected_endpoints"=>["user_create", "session_create"]})

        do_request
        expect_status_to_eq 201
      end

      it 'require captcha if endpoint is in the protection list' do
        allow(BarongConfig).to receive(:list).and_return({"сaptcha_protected_endpoints"=>["user_create", "session_create", "password_reset"]})

        do_request
        expect_status_to_eq 400
        expect_body.to eq(errors: ["identity.captcha.required"])
      end
    end
  end

  describe 'PUT /api/v2/identity/users/password/confirm_code' do
    let(:do_request) do
      post '/api/v2/identity/users/password/confirm_code', params: params
    end
    let(:params) do
      {
        reset_password_token: reset_password_token,
        password: password,
        confirm_password: confirm_password
      }
    end
    let(:reset_password_token) { '' }
    let(:password) { '' }
    let(:confirm_password) { '' }

    context 'when params are blank' do
      it 'renders 422 error' do
        do_request
        expect_status_to_eq 422
        expect_body.to eq(errors: ["identity.user.empty_reset_password_token", "identity.user.empty_password", "identity.user.empty_confirm_password"])
      end
    end

    context 'when Reset Password Token is invalid' do
      let(:reset_password_token) { 'invalid' }
      let(:password) { 'Gol4aid2' }
      let(:confirm_password) { 'Gol4aid2' }

      it 'renders 403 error' do
        do_request
        expect_status_to_eq 403
        expect_body.to eq(errors: ["jwt.decode_and_verify"])
      end
    end

    context 'when Reset Password Token and Password are valid ' do
      let!(:user) { create(:user) }
      let(:reset_password_token) { codec.encode(sub: 'reset', email: user.email, uid: user.uid) }
      let(:password) { 'ZahSh8ei' }
      let(:confirm_password) { 'ZahSh8ei' }
      let(:log_in) { post '/api/v2/identity/sessions', params: { email: user.email, password: password } }

      it 'resets a password' do
        do_request
        expect_status_to_eq 201
        log_in
        expect_status_to_eq 200
      end
    end

    context 'When Reset Password Token is valid, passwords are weak' do
      let!(:user) { create(:user) }
      let(:reset_password_token) { codec.encode(sub:'reset', email: user.email, uid: user.uid) }
      let(:password) { 'Simple' }
      let(:confirm_password) { 'Simple' }

      it 'returns weak password error' do
        do_request
        expect_status_to_eq 422
        expect_body.to eq(errors: ["password.requirements", "password.password.password_strength"])
      end
    end

    context 'When Reset Password Token is valid, passwords don\'t match' do
      let!(:user) { create(:user) }
      let(:reset_password_token) { codec.encode(sub: 'reset', email: user.email, uid: user.uid) }
      let(:password) { 'ZahSh8exwdi' }
      let(:confirm_password) { 'ZahSh8ei' }

      it 'returns 422 error' do
        do_request
        expect_status_to_eq 422
        expect_body.to eq(errors: ["identity.user.passwords_doesnt_match"])
      end
    end
  end
end
