# frozen_string_literal: true

describe 'Api::V2::APIKeys' do
  include_context 'bearer authentication'
  let!(:create_provider_permission) do
    create :permission,
           role: 'provider'
  end
  let!(:create_service_account_permission) do
    create :permission,
           role: 'service_account'
  end
  let!(:create_admin_permission) do
    create :permission,
           role: 'admin'
  end
  let!(:test_user) { create(:user, otp: otp_enabled, role: 'provider') }
  let!(:service_account) { create(:service_account, user: test_user) }
  let(:otp_enabled) { true }
  let!(:first_api_key) { create :api_key, key_holder_account: service_account }
  let!(:second_api_key) { create :api_key, key_holder_account: service_account }
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
    let(:get_params) do
      {
          service_account_uid: service_account.uid,
          ordering: 'asc',
          oreder_by: 'id'
      }
    end
    let(:post_params) do
      {
        service_account_uid: service_account.uid,
        scope: 'trade',
        algorithm: 'HS256'
      }
    end
    let(:do_request) do
      post '/api/v2/resource/providers/api_keys',
           params: post_params.merge(totp_code: otp_code),
           headers: auth_header
    end
    let(:do_get_request) { get "/api/v2/resource/providers/api_keys", params: get_params, headers: auth_header }
    let(:expected_fields) do
      {
        kid: first_api_key.kid,
        state: first_api_key.state,
        scope: %w[trade]
      }
    end
    let(:totp_code) { valid_otp_code }

    it 'Return api key for current account in ASC order' do
      do_get_request

      expect(json_body.count).to eq 2
      expect(response.status).to eq(200)
      expect(json_body.first).to include(expected_fields)
    end

    it 'Return api key for current account in DESC order' do
      get_params.merge!(ordering: 'desc')
      do_get_request

      expect(json_body.count).to eq 2
      expect(response.status).to eq(200)
      expect(json_body.second).to include(expected_fields)
    end

    context 'when invalid ordering' do
      it 'renders an error' do
        get_params.merge!(ordering: 'resc')
        do_get_request

        expect(response.status).to eq(422)
        expect_body.to eq(errors: ["resource.providers.invalid_ordering"])
      end
    end

    context 'when invalid order_by' do
      it 'renders an error' do
        get_params.merge!(order_by: 'invalid')
        do_get_request

        expect(response.status).to eq(422)
        expect_body.to eq(errors: ["resource.providers.invalid_attribute"])
      end
    end

    context 'when otp is not enabled' do
      let(:otp_enabled) { false }

      it 'renders an error' do
        do_request
        expect(response.status).to eq(400)
        expect_body.to eq(errors: ["resource.providers.2fa_disabled"])
      end
    end

    context 'when code is invalid' do
      let(:otp_code) { invalid_otp_code }

      it 'renders an error' do
        do_request
        expect(response.status).to eq(422)
        expect_body.to eq(errors: ["resource.providers.invalid_totp"])
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

      it 'does not create api key if vault is down' do
        allow(Vault::Rails).to receive(:encrypt).and_raise(Vault::VaultError)
        expect { do_request }.not_to change { APIKey.count }
        expect(response.status).to eq(422)
        expect_body.to eq(errors: ["api_key.could_not_save_secret"])
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
          expect_body.to eq(errors: ["resource.api_key.invalid_totp"])
        end
      end

      context 'when algorithm is invalid' do
        it 'renders an error' do
          params[:algorithm] = 'kek'
          do_request
          expect_body.to eq(errors: ["kid.blank", "algorithm.inclusion"])
        end
      end
    end
  end

  describe 'PUT /api/v2/resource/providers/api_keys/:kid' do
    let(:do_request) do
      put "/api/v2/resource/providers/api_keys/#{first_api_key.kid}", params: params.merge(totp_code: otp_code),
                                               headers: auth_header
    end
    let(:otp_code) { valid_otp_code }
    context 'when valid fields' do
      let(:params) do
        {
          service_account_uid: service_account.uid,
          state: 'inactive',
          scope: 'sell',
          algorithm: 'HS256'
        }
      end

      it 'Updates a state' do
        expect { do_request }.to change { first_api_key.reload.state }
          .from('active').to('inactive')
        expect(response.status).to eq(200)
      end

      it 'Updates a scope' do
        expect { do_request }.to change { first_api_key.reload.scope }
          .from(['trade']).to(['sell'])
        expect(response.status).to eq(200)
      end

      context 'when otp is not enabled' do
        let(:otp_enabled) { false }

        it 'renders an error' do
          do_request
          expect(response.status).to eq(400)
          expect_body.to eq(errors: ["resource.providers.2fa_disabled"])
        end
      end

      context 'when code is invalid' do
        let(:otp_code) { invalid_otp_code }

        it 'renders an error' do
          do_request
          expect(response.status).to eq(422)
          expect_body.to eq(errors: ["resource.providers.invalid_totp"])
        end
      end
    end
  end

  describe 'DELETE /api/v2/resource/providers/api_keys/:uid' do
    let(:do_request) do
      delete "/api/v2/resource/providers/api_keys/#{first_api_key.kid}?totp_code=#{otp_code}&service_account_uid=#{service_account.uid}",
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
        expect_body.to eq(errors: ["resource.providers.2fa_disabled"])
      end
    end

    context 'when code is invalid' do
      let(:otp_code) { invalid_otp_code }

      it 'renders an error' do
        do_request
        expect(response.status).to eq(422)
        expect_body.to eq(errors: ["resource.providers.invalid_totp"])
      end
    end
  end
end
