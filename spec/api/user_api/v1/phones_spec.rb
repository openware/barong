# frozen_string_literal: true

require 'spec_helper'

describe 'Api::V1::Phones' do
  include_context 'doorkeeper authentication'

  describe 'POST /api/v1/phones' do
    let(:do_request) do
      post '/api/v1/phones', params: params, headers: auth_header
    end
    let(:params) { { phone_number: phone_number } }

    context 'when phone is missing' do
      let(:phone_number) { nil }

      it 'renders an error' do
        do_request
        expect_body.to eq(error: 'Phone Number is empty')
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

    context 'when phone is already exists' do
      let!(:phone) do
        create(:phone, validated_at: validated_at)
      end
      let(:phone_number) { phone.number }

      context 'when phone verified' do
        let(:validated_at) { 1.minutes.ago }

        it 'renders an error' do
          do_request
          expect_body.to eq(error: 'Phone number already exists')
          expect_status.to eq 400
        end
      end

      context 'when phone verified but number is not sanitized' do
        let(:validated_at) { 1.minutes.ago }
        let(:phone_number) { "++#{phone.number}" }

        it 'renders an error' do
          do_request
          expect_body.to eq(error: 'Phone number already exists')
          expect_status.to eq 400
        end
      end

      context 'when phone is not verified' do
        let(:validated_at) { nil }

        it 'assigns a phone to account and send sms' do
          do_request
          expect_status.to eq 201
          expect(FakeSMS.messages.last.to).to eq "+#{phone_number}"
          expect_body.to eq(message: 'Code was sent successfully')
        end
      end
    end

    context 'when phone is valid' do
      let(:phone_number) { build(:phone).number }

      it 'creates a phone and send sms' do
        do_request
        expect_status.to eq 201
        expect(FakeSMS.messages.last.to).to eq "+#{phone_number}"
        expect_body.to eq(message: 'Code was sent successfully')
      end
    end

    context 'when phone is on national format with zero' do
      let(:phone_number) { '+44 07418084106' }
      let(:international_phone) { '447418084106' }

      it 'creates a phone and send sms' do
        do_request
        expect_status.to eq 201
        expect(FakeSMS.messages.last.to).to eq "+#{international_phone}"
        expect(Phone.last.number).to eq(international_phone)
      end
    end

    context 'when phone exists on international format' do
      let(:phone_number) { '+44 07418084106' }
      let(:international_phone) { '447418084106' }
      let!(:phone) do
        create(:phone, validated_at: 1.minute.ago, number: international_phone)
      end

      it 'renders an error' do
        do_request
        expect_body.to eq error: 'Phone number already exists'
        expect_status.to eq 400
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

    context 'when phone is missing and code is missing' do
      let(:phone_number) { nil }
      let(:verification_code) { '' }

      it 'renders an error' do
        do_request
        expect_body.to eq(error: 'Phone Number is empty, Verification Code is empty')
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
        expect_body.to eq(error: 'Phone number already exists')
        expect_status.to eq 400
      end
    end

    context 'when phone exists in international format' do
      let!(:phone) do
        create(:phone, validated_at: 1.minutes.ago, number: international_phone)
      end
      let(:phone_number) { '+44 07418084106' }
      let(:international_phone) { '447418084106' }

      it 'renders an error' do
        do_request
        expect_body.to eq(error: 'Phone number already exists')
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
      let!(:current_account) { create(:account) }
      let!(:phone) { create(:phone, account: current_account) }
      let(:phone_number) { phone.number }
      let(:verification_code) { phone.code }

      it 'responses with success' do
        set_level(current_account, 1)
        do_request
        expect_status.to eq 201
        expect(phone.reload.validated_at).to be
        expect(current_account.reload.level).to eq 2
        expect_body.to eq(message: 'Phone was verified successfully')
      end
    end
  end
end
