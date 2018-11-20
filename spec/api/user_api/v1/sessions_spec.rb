# frozen_string_literal: true

describe 'Session create test' do
  describe 'POST /api/v1/sessions' do
    let!(:email) { 'user@gmail.com' }
    let!(:password) { 'testPassword111' }
    let(:uri) { '/api/v1/sessions' }
    let(:check_uri) { '/api/v1/security/renew' }
    let!(:application) { create :doorkeeper_application }
    subject!(:acc) do
      create :account,
             email: email,
             password: password,
             password_confirmation: password,
             otp_enabled: otp_enabled
    end
    let(:otp_enabled) { false }

    context 'With valid params' do
      let(:do_request) { post uri, params: params }
      let(:params) do
        {
          email: email,
          password: password,
          application_id: application.uid
        }
      end

      it 'Checks current credentials and returns valid JWT' do
        do_request
        expect_status.to eq(201)
        response_jwt = JSON.parse(response.body)

        post check_uri,
             headers: { Authorization: "Bearer #{response_jwt}" }
        expect(response.status).to eq(201)
      end

      context 'when account was locked' do
        before { acc.lock_access! }
        it 'does not log in' do
          do_request
          expect_status.to eq(401)
          expect_body.to eq(error: 'Your account was locked!')
        end

        it 'unlocks account after an hour' do
          travel 65.minutes
          do_request
          expect_status.to eq(201)
        end
      end

      context 'when captcha is enabled' do
        before do
          ENV['CAPTCHA_ENABLED'] = 'true'
          ENV['CAPTCHA_ATTEMPTS'] = captcha_attempts.to_s
        end
        after do
          ENV['CAPTCHA_ENABLED'] = nil
          ENV['CAPTCHA_ATTEMPTS'] = nil
        end

        let(:captcha_attempts) { 3 }
        let(:recaptcha_response) { nil }
        let(:valid_response) { 'valid' }
        let(:invalid_response) { 'invalid' }

        before do
          allow_any_instance_of(RecaptchaVerifier).to receive(:verify_recaptcha)
            .with(model: acc,
                  skip_remote_ip: true,
                  response: valid_response) { true }

          allow_any_instance_of(RecaptchaVerifier).to receive(:verify_recaptcha)
            .with(model: acc,
                  skip_remote_ip: true,
                  response: invalid_response) { raise StandardError }
        end

        context 'when password is valid' do
          let(:params) do
            {
              email: email,
              password: password,
              application_id: application.uid,
              recaptcha_response: recaptcha_response
            }
          end

          context 'when account is reached captcha attempts' do
            before { acc.update!(failed_attempts: captcha_attempts) }

            context 'when captcha response is blank' do
              it 'signs in an account' do
                post uri, params: params
                expect_status_to_eq 201
              end
            end
          end
        end

        context 'when password is invalid' do
          let(:params) do
            {
              email: email,
              password: 'invalid',
              application_id: application.uid,
              recaptcha_response: recaptcha_response
            }
          end

          context 'when account is not reached captcha attempts' do
            it 'expects to get captcha error' do
              captcha_attempts.times do
                post uri, params: params
                expect_status_to_eq 401
              end

              post uri, params: params
              expect(json_body[:error]).to eq('recaptcha_response is required')
              expect_status_to_eq 420
            end
          end

          context 'when account is reached captcha attempts' do
            before { acc.update!(failed_attempts: captcha_attempts) }

            context 'when captcha response is blank' do
              it 'renders an error' do
                post uri, params: params
                expect(json_body[:error]).to eq('recaptcha_response is required')
                expect_status_to_eq 420
              end
            end

            context 'when captcha response is not valid' do
              let(:recaptcha_response) { invalid_response }

              it 'renders an error' do
                post uri, params: params
                expect(json_body[:error]).to eq('reCAPTCHA verification failed, please try again.')
                expect_status_to_eq 420
              end
            end

            context 'when captcha response is valid' do
              let(:recaptcha_response) { invalid_response }

              it 'resets failed attempts' do
                post uri, params: params.merge(recaptcha_response: valid_response)
                expect(json_body[:error]).to eq('Invalid Email or Password')
                expect_status_to_eq 401
              end
            end
          end
        end
      end

      context 'when account has enabled 2FA' do
        let(:otp_enabled) { true }

        it 'renders an error when code is missing' do
          do_request
          expect_status.to eq(403)
          expect_body.to eq(error: 'The account has enabled 2FA but OTP code is missing')
        end

        it 'renders an error when code is wrong' do
          params[:otp_code] = '1111'
          expect(Vault::TOTP).to receive(:validate?).with(acc.uid, '1111') { false }
          do_request
          expect_status.to eq(403)
          expect_body.to eq(error: 'OTP code is invalid')
        end

        it 'returns valid JWT when code is valid' do
          params[:otp_code] = '1111'
          expect(Vault::TOTP).to receive(:validate?).with(acc.uid, '1111') { true }
          do_request
          expect_status.to eq(201)
        end

        it 'locks account when OTP is wrong for a 5 times' do
          params[:otp_code] = '1111'
          allow(Vault::TOTP).to receive(:validate?).with(acc.uid, '1111') { false }
          5.times do
            post uri, params: params
          end
          do_request
          expect_body.to eq(error: 'Your account was locked!')
          expect_status.to eq(401)
        end
      end

      context 'when user has less than 5 failed attempts' do
        before do
          post uri, params: { email: email, password: 'password', application_id: application.uid }
        end

        it 'refreshes failed_attempts count' do
          expect(acc.reload.failed_attempts).to eq(1)
          do_request
          expect_status.to eq(201)
          expect(acc.reload.failed_attempts).to eq(0)
        end
      end
    end

    context 'With Invalid params' do
      context 'Checks current credentials and returns error' do
        it 'when email, password and application_id are missing' do
          post uri
          expect_body.to eq(error: 'Email is missing, Password is missing, Application ID is missing')
          expect(response.status).to eq(400)
        end

        it 'when Application ID is missing' do
          post uri, params: { email: 'rick@morty.io', password: 'season1' }
          expect_body.to eq(error: 'Application ID is missing')
          expect(response.status).to eq(400)
        end

        it 'when password and Application ID is missing' do
          post uri, params: { email: email }
          expect_body.to eq(error: 'Password is missing, Application ID is missing')
          expect(response.status).to eq(400)
        end

        it 'when Application ID is missing' do
          post uri, params: { email: email, password: password }
          expect_body.to eq(error: 'Application ID is missing')
          expect(response.status).to eq(400)
        end

        context 'when Password is wrong' do
          before { ENV['MAX_LOGIN_ATTEMPTS'] = max_attempts.to_s }
          after { ENV['MAX_LOGIN_ATTEMPTS'] = nil }
          let(:max_attempts) { 10 }

          it 'returns errror' do
            post uri, params: { email: email, password: 'password', application_id: application.uid }
            expect_body.to eq(error: 'Invalid Email or Password')
            expect(response.status).to eq(401)
          end

          it 'locks account if user has 5 failed attempts' do
            max_attempts.times do
              post uri, params: { email: email,  password: 'password', application_id: application.uid }
              expect_body.to eq(error: 'Invalid Email or Password')
            end
            post uri, params: { email: email,  password: 'password', application_id: application.uid }
            expect_body.to eq(error:  'Your account was locked!')
            post uri, params: { email: email,  password: password, application_id: application.uid }
            expect_body.to eq(error:  'Your account was locked!')
          end
        end

        it 'when Application ID is wrong' do
          post uri, params: { email: email, password: password, application_id: 'application.uid' }
          expect_body.to eq(error: 'Wrong Application ID')
          expect(response.status).to eq(401)
        end
      end

      context 'When user has not verified his email' do
        let!(:another_email) { 'email@random.com' }
        let!(:account) do
          create :account,
                 email: another_email,
                 password: password,
                 password_confirmation: password,
                 confirmed_at: nil
        end

        it 'returns error' do
          post uri, params: { email: another_email, password: password, application_id: application.uid }
          expect_body.to eq(error: 'You have to confirm your email address before continuing')
          expect(response.status).to eq(401)
        end
      end

      context 'When user is not active' do
        let!(:another_email) { 'email@random.com' }
        let!(:account) do
          create :account,
                 email: another_email,
                 password: password,
                 password_confirmation: password,
                 state: 'banned'
        end

        it 'returns error' do
          post uri, params: { email: another_email, password: password, application_id: application.uid }
          expect_body.to eq(error: 'You have to confirm your email address before continuing')
          expect(response.status).to eq(401)
        end
      end
    end
  end

  describe 'POST /api/v1/sessions/generate_jwt' do
    let(:do_request) do
      post '/api/v1/sessions/generate_jwt', params: params
    end
    let(:params) { {} }
    let!(:account) { create(:account) }
    let!(:api_key) do
      create(:api_key,
             account: account,
             public_key: jwt_keypair_encoded[:public])
    end

    context 'when required params are missing' do
      it 'renders an error' do
        do_request
        expect_status.to eq 400
        expect_body.to eq(error: 'KID is missing, KID is empty, JWT Token is missing, JWT Token is empty')
      end
    end

    context 'when key is not found' do
      let(:params) do
        {
          kid: 'invalid',
          jwt_token: 'invalid_token'
        }
      end
      it 'renders an error' do
        do_request
        expect_status.to eq 404
        expect_body.to eq(error: 'Record is not found')
      end
    end

    context 'when payload is invalid' do
      let(:params) do
        {
          kid: api_key.uid,
          jwt_token: 'invalid_token'
        }
      end
      it 'renders an error' do
        do_request
        expect_status.to eq 401
        expect(json_body[:error]).to include('Failed to decode and verify JWT')
      end
    end

    context 'when payload is valid' do
      let(:multiple_scopes_api_key) do
        create(:api_key,
               account: account,
               public_key: jwt_keypair_encoded[:public],
               scopes: %w[read_orders write_orders])
      end
      let(:params) do
        {
          kid: multiple_scopes_api_key.uid,
          jwt_token: encode_api_key_payload({})
        }
      end
      let(:expected_payload) do
        {
          sub: 'session',
          iss: 'barong',
          aud: multiple_scopes_api_key.scopes,
          email: account.email,
          level: account.level,
          role: account.role,
          state: account.state
        }
      end

      before do
        expect(Barong::Security).to \
          receive(:private_key) { build_ssl_pkey jwt_keypair_encoded[:private] }
        do_request
      end

      it { expect_status.to eq 200 }
      it 'generates valid session jwt' do
        token = json_body[:token]
        payload, = jwt_decode(token)
        expect(payload.symbolize_keys).to include(expected_payload)
      end

      it 'generates session jwt with comma separated scopes' do
        token = json_body[:token]
        payload, = jwt_decode(token)
        expect(payload['aud']).to eq multiple_scopes_api_key.scopes
      end
    end
  end
end
