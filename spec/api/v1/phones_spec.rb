require 'spec_helper'

describe 'Api::V1::Phones' do
  include_context 'doorkeeper authentication'

  describe 'POST /api/v1/phones' do
    let(:do_request) do
      post '/api/v1/phones', params: params, headers: auth_header
    end
    let(:params) {{ phone_number: phone_number }}

    before { do_request }

    context 'when phone is missing' do
      let(:phone_number) { nil }

      it 'renders an error' do
        do_request
        expect_body.to eq(error: 'phone_number is empty')
        expect_status.to eq 400
      end
    end

    context 'when phone is invalid' do
      let(:phone_number) { '123' }

      it 'renders an error' do
        do_request
        expect_body.to eq(error: 'Phone number is invalid')
        expect_status.to eq 400
      end
    end

    context 'when phone is already exists and verified' do
      let!(:phone) do
        create(:phone, validated_at: 1.minutes.ago)
      end
      let(:phone_number) { phone.number }

      it 'renders an error' do
        do_request
        expect_body.to eq(error: 'Phone number is already exists')
        expect_status.to eq 400
      end
    end

    context 'when phone is valid' do
      let(:phone_number) { build(:phone).number }

      it 'creates a phone and send sms' do
        do_request
        expect_status.to eq 201
      end
    end
  end

  describe 'POST /api/v1/phones/verify' do
    let(:do_request) do
      post '/api/v1/phones/verify', params: params, headers: auth_header
    end
    let(:params) do
      {
        phone_number: phone_number,
        verification_code: verification_code
      }
    end
    let(:verification_code) { '12345' }

    before { do_request }

    context 'when phone is missing and code is missing' do
      let(:phone_number) { nil }
      let(:verification_code) { '' }

      it 'renders an error' do
        do_request
        expect_body.to eq(error: 'phone_number is empty, verification_code is empty')
        expect_status.to eq 400
      end
    end

    context 'when phone is invalid' do
      let(:phone_number) { '123' }

      it 'renders an error' do
        do_request
        expect_body.to eq(error: 'Phone number is invalid')
        expect_status.to eq 400
      end
    end

    context 'when phone is already exists and verified' do
      let!(:phone) do
        create(:phone, validated_at: 1.minutes.ago)
      end
      let(:phone_number) { phone.number }

      it 'renders an error' do
        do_request
        expect_body.to eq(error: 'Phone number is already exists')
        expect_status.to eq 400
      end
    end

    context 'when phone is not found in current_account' do
      let!(:phone) { create(:phone) }
      let(:phone_number) { phone.number }

      it 'rendens an error' do
        do_request
        expect_body.to eq(error: 'Phone is not found or verification code is invalid')
        expect_status.to eq 404
      end
    end

    context 'when phone is found in current_account but code is invalid' do
      let!(:phone) { create(:phone, account: current_account) }
      let(:phone_number) { phone.number }

      it 'rendens an error' do
        do_request
        expect_body.to eq(error: 'Phone is not found or verification code is invalid')
        expect_status.to eq 404
      end
    end

    context 'when phone and code is valid' do
      let!(:current_account) { create(:account, level: 1) }
      let!(:phone) { create(:phone, account: current_account) }
      let(:phone_number) { phone.number }
      let(:verification_code) { phone.code }

      it 'responses with success' do
        do_request
        expect_status.to eq 201
        expect(phone.reload.validated_at).to be
        expect(current_account.reload.level).to eq 2
      end
    end
  end
end
