# frozen_string_literal: true

describe 'Session create test' do
  describe 'POST /api/v1/sessions' do
    let(:device_uid) { '' }
    let!(:device) do
      create(:device, account: current_account,
                      last_sign_in: 1.day.ago)
    end
    let!(:email) { 'user@gmail.com' }
    let!(:password) { 'testPassword111' }
    let(:uri) { '/api/v1/sessions' }
    let(:check_uri) { '/api/v1/security/renew' }
    let!(:application) { create :doorkeeper_application }
    subject!(:current_account) do
      create :account,
             email: email,
             password: password,
             password_confirmation: password,
             otp_enabled: otp_enabled
    end
    let(:otp_enabled) { false }
    before do
      cookies[:device_uid] = device_uid
    end

    context 'With valid params' do
      let(:do_request) { post uri, params: params }
      let(:remember_me) { nil }
      let(:params) do
        {
          email: email,
          password: password,
          application_id: application.uid,
          remember_me: remember_me
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

      it 'does not create any device by default' do
        expect { do_request }.to_not change { Device.count }
      end

      context 'when params has remember_me option' do
        let(:remember_me) { 'true' }

        it 'creates a device by default and saves a session' do
          expect { do_request }.to change { Device.count }.by(1)
          expect(response.status).to eq(201)
        end

        context 'when device is already exists' do
          let(:device_uid) { device.uid }

          it 'does not create any device' do
            expect { do_request }.to_not change { Device.count }
            expect(response.status).to eq(201)
          end
        end
      end

      context 'when session has valid device_uid' do
        let(:device_uid) { device.uid }

        it 'updates last_sign_in' do
          expect { do_request }.to change { device.reload.last_sign_in }
          expect(response.status).to eq(201)
        end
      end

      context 'when account has enabled 2FA' do
        before do
          allow(Vault::TOTP).to receive(:validate?)
            .with(current_account.uid, valid_code) { true }

          allow(Vault::TOTP).to receive(:validate?)
            .with(current_account.uid, invalid_code) { false }
        end

        let(:valid_code) { '12345' }
        let(:invalid_code) { '11111' }
        let(:otp_enabled) { true }

        it 'renders an error when code is missing' do
          expect { do_request }.to_not change { Device.count }
          expect_status.to eq(403)
          expect_body.to eq(error: 'The account has enabled 2FA but OTP code is missing')
        end

        it 'renders an error when code is wrong' do
          params[:otp_code] = invalid_code
          expect { do_request }.to_not change { Device.count }
          expect_status.to eq(403)
          expect_body.to eq(error: 'OTP code is invalid')
        end

        it 'returns valid JWT when code is valid' do
          params[:otp_code] = valid_code
          expect { do_request }.to_not change { Device.count }
          expect_status.to eq(201)
        end

        context 'when params has remember_me option' do
          let(:remember_me) { 'true' }

          it 'creates a device by default and saves a session' do
            params[:otp_code] = valid_code
            expect { do_request }.to change { Device.count }.by(1)
            expect(response.status).to eq(201)
          end

          context 'when device is already exists' do
            let(:device_uid) { device.uid }

            it 'does not create any device' do
              params[:otp_code] = valid_code
              expect { do_request }.to_not change { Device.count }
              expect(response.status).to eq(201)
            end

            it 'updates a check_otp_time' do
              params[:otp_code] = valid_code
              expect { do_request }.to change { device.reload.check_otp_time }
              expect(response.status).to eq(201)
            end
          end
        end

        context 'when session has valid device_uid' do
          let!(:device) do
            create(:device, account: current_account,
                            check_otp_time: check_otp_time,
                            last_sign_in: 1.day.ago)
          end
          let(:device_uid) { device.uid }

          context 'when check_otp_time in future' do
            let(:check_otp_time) { 1.days.from_now }

            it 'does not check otp ' do
              params[:otp_code] = nil
              expect { do_request }.to change { device.reload.last_sign_in }
              expect(response.status).to eq(201)
            end
          end

          context 'when check_otp_time is current time' do
            let(:check_otp_time) { Time.current }

            it 'checks an otp' do
              params[:otp_code] = nil
              expect { do_request }.to_not change { device.reload.last_sign_in }
              expect(response.status).to eq(403)
            end
          end

          # it 'updates check_otp_time' do
          #   params[:otp_code] = valid_code
          #   expect { do_request }.to change { device.reload.check_otp_time }
          #   expect(response.status).to eq(201)
          # end
        end

        context 'when check otp time exists' do
          let(:device_uid) { device.uid }
        end

        it 'locks account when OTP is wrong for a 5 times' do
          params[:otp_code] = '1111'
          allow(Vault::TOTP).to receive(:validate?).with(current_account.uid, '1111') { false }
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
          expect(current_account.reload.failed_attempts).to eq(1)
          do_request
          expect_status.to eq(201)
          expect(current_account.reload.failed_attempts).to eq(0)
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
          it 'returns errror' do
            post uri, params: { email: email, password: 'password', application_id: application.uid }
            expect_body.to eq(error: 'Invalid Email or Password')
            expect(response.status).to eq(401)
          end

          it 'locks account if user has 5 failed attempts' do
            5.times do
              post uri, params: { email: email,  password: 'password', application_id: application.uid }
              expect_body.to eq(error: 'Invalid Email or Password')
            end
            post uri, params: { email: email,  password: 'password', application_id: application.uid }
            expect_body.to eq(error:  'Your account was locked!')
            post uri, params: { email: email,  password: password, application_id: application.uid }
            expect_body.to eq(error:  'Your account was locked!')
          end
        end

        it 'when email is wrong' do
          post uri, params: { email: 'wrong@email.com', password: 'password', application_id: application.uid }
          expect_body.to eq(error: 'Invalid Email or Password')
          expect(response.status).to eq(401)
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
    end
  end

  describe 'POST /api/v1/sessions/generate_jwt' do
    let(:do_request) do
      post '/api/v1/sessions/generate_jwt', params: params
    end
    let(:params) { {} }
    let!(:account) { create(:account) }
    let!(:api_key) do
      create(:api_key, account: account,
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
      let(:params) do
        {
          kid: api_key.uid,
          jwt_token: encode_api_key_payload({})
        }
      end
      let(:expected_payload) do
        {
          sub: 'session',
          iss: 'barong',
          aud: api_key.scopes,
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
    end
  end
end
