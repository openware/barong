# frozen_string_literal: true

describe 'Api::V2::Resources::Phones' do

  include_context 'bearer authentication'
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  describe 'GET /api/v2/resource/phones' do
    let!(:phone1) { create(:phone, user: test_user) }
    let!(:phone2) { create(:phone, user: test_user, number: 12345677711 ) }
    let(:do_request) do
      get '/api/v2/resource/phones', headers: auth_header
    end

    it 'returns list of user\'s phones' do
      do_request

      expect(json_body.length).to eq 2
      expect(json_body.first[:number]).to eq phone1.number
      expect(json_body.first[:country]).to eq phone1.country
      expect(json_body.first[:validated_at]).to eq phone1.validated_at
      expect(json_body.second[:number]).to eq phone2.number
      expect(json_body.second[:country]).to eq phone2.country
      expect(json_body.second[:validated_at]).to eq phone2.validated_at
    end
  end

  describe 'POST /api/v2/resource/phones' do
    let(:do_request) do
      post '/api/v2/resource/phones', params: params, headers: auth_header
    end
    let(:params) { { phone_number: phone_number } }
    let(:mock_sms) { Barong::MockSMS }

    context 'when phone is missing' do
      let(:phone_number) { nil }

      it 'renders an error' do
        do_request
        expect_body.to eq(errors: ["resource.phone.empty_phone_number"])
        expect_status.to eq 422
      end
    end

    context 'when phone is invalid' do
      let(:phone_number) { '123' }

      it 'renders an error' do
        do_request
        expect_body.to eq(errors: ["resource.phone.invalid_num"])
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
          expect_body.to eq(errors: ["resource.phone.number_exist"])
          expect_status.to eq 400
        end
      end

      context 'when phone verified but number is not sanitized' do
        let(:validated_at) { 1.minutes.ago }
        let(:phone_number) { "++#{phone.number}" }

        it 'renders an error' do
          do_request
          expect_body.to eq(errors: ["resource.phone.number_exist"])
          expect_status.to eq 400
        end
      end

      context 'when phone is not verified' do
        let(:validated_at) { nil }

        it 'assigns a phone to account and send sms' do
          do_request
          expect_body.to eq(message: 'Code was sent successfully')
          expect_status.to eq 201
          expect(mock_sms.messages.last.to).to eq "+#{phone_number}"
        end
      end
    end

    context 'when phone is valid' do
      let(:phone_number) { build(:phone).number }

      it 'creates a phone and send sms' do
        do_request
        expect_body.to eq(message: 'Code was sent successfully')
        expect_status.to eq 201
        expect(mock_sms.messages.last.to).to eq "+#{phone_number}"
      end

      it 'doesnt change code in DB on phone initialize' do
        do_request
        expect_body.to eq(message: 'Code was sent successfully')
        expect_status.to eq 201
        code_after_create = Phone.last.code
        # Phone.last initilazes phone
        code_after_initialize = Phone.last.code
        expect(code_after_create).to eq code_after_initialize
      end
    end

    context 'when phone is on national format with zero' do
      let(:phone_number) { '+44 07418084106' }
      let(:international_phone) { '447418084106' }

      it 'creates a phone and send sms' do
        do_request
        expect_body.to eq(message: 'Code was sent successfully')
        expect_status.to eq 201
        expect(mock_sms.messages.last.to).to eq "+#{international_phone}"
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
        expect_body.to eq errors: ["resource.phone.number_exist"]
        expect_status.to eq 400
      end
    end
  end

  describe 'POST /api/v2/resource/phones/verify' do
    let(:do_request) do
      post '/api/v2/resource/phones/verify', params: params, headers: auth_header
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
        expect_body.to eq(errors: ["resource.phone.empty_phone_number", "resource.phone.empty_verification_code"])
        expect_status.to eq 422
      end
    end

    context 'when phone is invalid' do
      let(:phone_number) { '123' }

      it 'renders an error' do
        do_request
        expect_body.to eq(errors: ["resource.phone.invalid_num"])
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
        expect_body.to eq(errors: ["resource.phone.number_exist"])
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
      expect_body.to eq(errors: ["resource.phone.number_exist"])
      expect_status.to eq 400
    end
  end

  context 'when phone is not found in test_user' do
    let!(:phone) { create(:phone) }
    let(:phone_number) { phone.number }

    it 'rendens an error' do
      do_request
      expect_body.to eq(errors: ["resource.phone.verification_invalid"])
      expect_status.to eq 404
    end
  end

  context 'when phone is found in test_user but code is invalid' do
    let!(:phone) { create(:phone, user: test_user) }
    let(:phone_number) { phone.number }

    it 'rendens an error' do
      do_request
      expect_body.to eq(errors: ["resource.phone.verification_invalid"])
      expect_status.to eq 404
    end
  end

  context 'when phone and code is valid' do
    let(:phone) { create(:phone, user: test_user) }
    let(:phone_number) { phone.number }
    let(:verification_code) { phone.code }

    it 'responses with success' do
      set_level(test_user, 1)
      do_request
      expect_body.to eq(message: 'Phone was verified successfully')
      expect_status.to eq 201
      expect(phone.reload.validated_at).to be
      test_user.update_level
      expect(test_user.reload.level).to eq 2
    end
  end
end
end
