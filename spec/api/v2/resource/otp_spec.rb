# frozen_string_literal: true

describe 'Api::V2::Resource::Otp' do
  include_context 'bearer authentication'
  include_context 'geoip mock'

  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  let(:do_request) { post '/api/v2/resource/otp/enable', headers: auth_header }
  let(:otp_code) { '111111' }

  context 'valid request' do
    before do
      allow(TOTPService).to receive(:validate?)
      .with(test_user.uid, otp_code) { true }
    end

    it 'user enables 2fa successfully' do
      post '/api/v2/resource/otp/enable', headers: auth_header, params: {
        code: otp_code
      }

      expect(response.status).to eq 201
      expect(test_user.reload.otp).to eq true
      expect(test_user.reload.labels.find_by(key: :otp, scope: :private)).not_to eq nil
    end
  end

  context 'incomplete request' do
    it 'user receives error' do
      post '/api/v2/resource/otp/enable', headers: auth_header, params: {
        code: otp_code
      }

      expect(response.status).to eq 422
      expect(test_user.reload.otp).to eq false
      expect(test_user.reload.labels.find_by(key: :otp, scope: :private)).to eq nil
    end
  end
end
