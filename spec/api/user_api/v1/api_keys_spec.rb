# frozen_string_literal: true

describe 'Api::V1::APIKeys' do
  include_context 'doorkeeper authentication'
  let!(:current_account) do
    create(:account, otp_enabled: otp_enabled)
  end
  let(:otp_enabled) { true }
  let!(:api_key) { create :api_key, account: current_account }
  let(:valid_otp_code) { '1357' }
  let(:invalid_otp_code) { '1234' }

  before do
    allow(Vault::TOTP).to receive(:validate?)
      .with(current_account.uid, valid_otp_code) { true }
    allow(Vault::TOTP).to receive(:validate?)
      .with(current_account.uid, invalid_otp_code) { false }
    allow(Vault::TOTP).to receive(:validate?)
      .with(current_account.uid, nil) { false }
  end

  describe 'GET /api/v1/api_keys' do
    let(:do_request) { get "/api/v1/api_keys?totp_code=#{totp_code}", headers: auth_header }
    let(:totp_code) { valid_otp_code }

    it 'Return api keys for current account' do
      do_request
      expect(response.status).to eq(200)
      expect(json_body.size).to eq(1)
      expect(json_body.first[:uid]).to eq(api_key.uid)
    end

    context 'when otp is not enabled' do
      let(:otp_enabled) { false }

      it 'renders an error' do
        do_request
        expect(response.status).to eq(400)
        expect_body.to eq(error: 'Only accounts with enabled 2FA alowed')
      end
    end

    context 'when code is invalid' do
      let(:totp_code) { invalid_otp_code }

      it 'renders an error' do
        do_request
        expect(response.status).to eq(422)
        expect_body.to eq(error: 'OTP code is invalid')
      end
    end
  end

  describe 'GET /api/v1/api_keys/:uid' do
    let(:do_request) do
      get "/api/v1/api_keys/#{api_key.uid}?totp_code=#{totp_code}",
          headers: auth_header
    end
    let(:expected_fields) do
      {
        uid: api_key.uid,
        public_key: api_key.public_key,
        state: api_key.state,
        scopes: %w[trade]
      }
    end
    let(:totp_code) { valid_otp_code }

    it 'Return api key for current account' do
      do_request
      expect(response.status).to eq(200)
      expect(json_body).to include(expected_fields)
    end

    context 'when otp is not enabled' do
      let(:otp_enabled) { false }

      it 'renders an error' do
        do_request
        expect(response.status).to eq(400)
        expect_body.to eq(error: 'Only accounts with enabled 2FA alowed')
      end
    end

    context 'when code is invalid' do
      let(:totp_code) { invalid_otp_code }

      it 'renders an error' do
        do_request
        expect(response.status).to eq(422)
        expect_body.to eq(error: 'OTP code is invalid')
      end
    end
  end

  describe 'POST /api/v1/api_keys' do
    let(:do_request) do
      post '/api/v1/api_keys',
           params: params.merge(totp_code: totp_code),
           headers: auth_header
    end
    let(:totp_code) { valid_otp_code }

    context 'when fields are valid' do
      let(:params) do
        {
          scopes: 'trade',
          public_key: Faker::Crypto.sha256
        }
      end
      let(:expected_fields) do
        {
          uid: instance_of(String),
          public_key: params[:public_key],
          state: 'active',
          scopes: params[:scopes].split(','),
          expires_in: 1.day.to_i
        }
      end

      it 'Create an api key' do
        expect { do_request }.to change { APIKey.count }.by(1)
        expect(response.status).to eq(201)
        expect_body.to include(expected_fields)
      end

      it 'sets expires_in' do
        params[:expires_in] = 2.hours.to_i
        expected_fields[:expires_in] = 2.hours.to_i
        expect { do_request }.to change { APIKey.count }.by(1)
        expect(response.status).to eq(201)
        expect_body.to include(expected_fields)
      end

      context 'when otp is not enabled' do
        let(:otp_enabled) { false }

        it 'renders an error' do
          do_request
          expect(response.status).to eq(400)
          expect_body.to eq(error: 'Only accounts with enabled 2FA alowed')
        end
      end

      context 'when code is invalid' do
        let(:totp_code) { invalid_otp_code }

        it 'renders an error' do
          do_request
          expect(response.status).to eq(422)
          expect_body.to eq(error: 'OTP code is invalid')
        end
      end
    end

    context 'when expires in is greater than allowed' do
      let(:params) do
        {
          public_key: Faker::Crypto.sha256,
          expires_in: 1.day.to_i + 1
        }
      end

      it 'renders an error' do
        expect { do_request }.to_not change { APIKey.count }
        expect(response.status).to eq(422)
        expect_body.to eq(error: 'Expires in must be less than or equal to 86400')
      end
    end
  end

  describe 'PATCH /api/v1/api_keys/:uid' do
    let(:do_request) do
      patch "/api/v1/api_keys/#{api_key.uid}", params: params.merge(totp_code: totp_code),
                                               headers: auth_header
    end
    let(:totp_code) { valid_otp_code }
    context 'when valid fields' do
      let(:params) do
        {
          public_key: Faker::Crypto.sha256,
          expires_in: 1.hour.to_i,
          state: 'inactive'
        }
      end

      it 'Updates an api key' do
        expect { do_request }.to change { api_key.reload.public_key }.to(params[:public_key])
        expect(response.status).to eq(200)
      end

      it 'Updates a state' do
        expect { do_request }.to change { api_key.reload.state }
          .from('active').to('inactive')
        expect(response.status).to eq(200)
      end

      it 'Updates an api key expires in' do
        expect { do_request }.to change { api_key.reload.expires_in }
          .from(1.day.to_i).to(1.hour.to_i)
        expect(response.status).to eq(200)
      end

      context 'when otp is not enabled' do
        let(:otp_enabled) { false }

        it 'renders an error' do
          do_request
          expect(response.status).to eq(400)
          expect_body.to eq(error: 'Only accounts with enabled 2FA alowed')
        end
      end

      context 'when code is invalid' do
        let(:totp_code) { invalid_otp_code }

        it 'renders an error' do
          do_request
          expect(response.status).to eq(422)
          expect_body.to eq(error: 'OTP code is invalid')
        end
      end
    end

    context 'when expires in is greater than allowed' do
      let(:params) do
        {
          expires_in: 1.day.to_i + 1
        }
      end

      it 'renders an error' do
        expect { do_request }.to_not change { APIKey.count }
        expect(response.status).to eq(422)
        expect_body.to eq(error: 'Expires in must be less than or equal to 86400')
      end
    end
  end

  describe 'DELETE /api/v1/api_keys/:uid' do
    let(:do_request) do
      delete "/api/v1/api_keys/#{api_key.uid}?totp_code=#{totp_code}",
             headers: auth_header
    end
    let(:totp_code) { valid_otp_code }

    it 'Removes an api key' do
      do_request
      expect(response.status).to eq(204)
    end

    context 'when otp is not enabled' do
      let(:otp_enabled) { false }

      it 'renders an error' do
        do_request
        expect(response.status).to eq(400)
        expect_body.to eq(error: 'Only accounts with enabled 2FA alowed')
      end
    end

    context 'when code is invalid' do
      let(:totp_code) { invalid_otp_code }

      it 'renders an error' do
        do_request
        expect(response.status).to eq(422)
        expect_body.to eq(error: 'OTP code is invalid')
      end
    end
  end
end
