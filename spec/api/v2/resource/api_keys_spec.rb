# frozen_string_literal: true

describe 'Api::V2::APIKeys' do
  include_context 'bearer authentication'
  let!(:test_user) { create(:user, otp: otp_enabled) }
  let(:otp_enabled) { true }
  let!(:api_key) { create :api_key, user: test_user }
  let(:valid_otp_code) { '1357' }
  let(:invalid_otp_code) { '1234' }
  let(:otp_code) { valid_otp_code }

  before do
    allow(TOTPService).to receive(:validate?)
      .with(test_user.uid, valid_otp_code) { true }
    allow(TOTPService).to receive(:validate?)
      .with(test_user.uid, invalid_otp_code) { false }
    allow(TOTPService).to receive(:validate?)
      .with(test_user.uid, nil) { false }
  end

  describe 'GET /api/v2/resource/api_keys/' do
    let(:do_request) { get "/api/v2/resource/api_keys/?totp_code=#{otp_code}", headers: auth_header }
    let(:expected_fields) do
      {
        kid: api_key.kid,
        state: api_key.state,
        scope: %w[trade]
      }
    end
    let(:totp_code) { valid_otp_code }

    it 'Return api key for current account' do
      do_request
      expect(response.status).to eq(200)
      expect(json_body.first).to include(expected_fields)
    end

    context 'when otp is not enabled' do
      let(:otp_enabled) { false }

      it 'renders an error' do
        do_request
        expect(response.status).to eq(400)
        expect_body.to eq(errors: ["resource.api_key.2fa_disabled"])
      end
    end

    context 'when code is invalid' do
      let(:otp_code) { invalid_otp_code }

      it 'renders an error' do
        do_request
        expect(response.status).to eq(422)
        expect_body.to eq(errors: ["resource.api_key.invalid_otp"])
      end
    end
  end

  describe 'POST /api/v2/resource/api_keys' do
    let(:do_request) do
      post '/api/v2/resource/api_keys',
           params: params.merge(totp_code: otp_code),
           headers: auth_header
    end
    let(:otp_code) { valid_otp_code }

    context 'when fields are valid' do
      let(:params) do
        {
          scope: 'trade',
          algorithm: 'HS256'
        }
      end
      let(:expected_fields) do
        {
          state: 'active',
          scope: params[:scope].split(','),
          algorithm: 'HS256'
        }
      end

      it 'Create an api key' do
        expect { do_request }.to change { APIKey.count }.by(1)
        expect(response.status).to eq(201)
        expect_body.to include(expected_fields)
      end

      context 'when otp is not enabled' do
        let(:otp_enabled) { false }

        it 'renders an error' do
          do_request
          expect(response.status).to eq(400)
          expect_body.to eq(errors: ["resource.api_key.2fa_disabled"])
        end
      end

      context 'when code is invalid' do
        let(:otp_code) { invalid_otp_code }

        it 'renders an error' do
          do_request
          expect(response.status).to eq(422)
          expect_body.to eq(errors: ["resource.api_key.invalid_otp"])
        end
      end

      context 'when algorithm is invalid' do
        it 'renders an error' do
          params[:algorithm] = 'kek'
          do_request
          expect_body.to eq(error: "Kid can't be blank and Algorithm is not included in the list")
        end
      end
    end
  end

  describe 'PATCH /api/v2/resource/api_keys/:kid' do
    let(:do_request) do
      patch "/api/v2/resource/api_keys/#{api_key.kid}", params: params.merge(totp_code: otp_code),
                                               headers: auth_header
    end
    let(:otp_code) { valid_otp_code }
    context 'when valid fields' do
      let(:params) do
        {
          state: 'inactive',
          scope: 'sell',
          algorithm: 'HS256'
        }
      end

      it 'Updates a state' do
        expect { do_request }.to change { api_key.reload.state }
          .from('active').to('inactive')
        expect(response.status).to eq(200)
      end

      it 'Updates a scope' do
        expect { do_request }.to change { api_key.reload.scope }
          .from(['trade']).to(['sell'])
        expect(response.status).to eq(200)
      end

      context 'when otp is not enabled' do
        let(:otp_enabled) { false }

        it 'renders an error' do
          do_request
          expect(response.status).to eq(400)
          expect_body.to eq(errors: ["resource.api_key.2fa_disabled"])
        end
      end

      context 'when code is invalid' do
        let(:otp_code) { invalid_otp_code }

        it 'renders an error' do
          do_request
          expect(response.status).to eq(422)
          expect_body.to eq(errors: ["resource.api_key.invalid_otp"])
        end
      end
    end
  end

  describe 'DELETE /api/v2/resource/api_keys/:uid' do
    let(:do_request) do
      delete "/api/v2/resource/api_keys/#{api_key.kid}?totp_code=#{otp_code}",
             headers: auth_header
    end
    let(:otp_code) { valid_otp_code }

    it 'Removes an api key' do
      do_request
      expect(response.status).to eq(204)
    end

    context 'when otp is not enabled' do
      let(:otp_enabled) { false }

      it 'renders an error' do
        do_request
        expect(response.status).to eq(400)
        expect_body.to eq(errors: ["resource.api_key.2fa_disabled"])
      end
    end

    context 'when code is invalid' do
      let(:otp_code) { invalid_otp_code }

      it 'renders an error' do
        do_request
        expect(response.status).to eq(422)
        expect_body.to eq(errors: ["resource.api_key.invalid_otp"])
      end
    end
  end
end
