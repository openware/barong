# frozen_string_literal: true

describe 'Api::V2::Resources::Phones' do
  include_context 'bearer authentication'
  let!(:create_member_permission) do
    create :permission,
          role: 'member'
  end

  context 'Twilio Verify Service' do
    before do
      allow(Barong::App.config).to receive(:twilio_provider).and_return(TwilioVerifyService)
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

        expect(json_body.first[:number]).to eq phone1.sub_masked_number
        expect(json_body.first[:country]).to eq phone1.country
        expect(json_body.first[:validated_at]).to eq phone1.validated_at
        expect(json_body.second[:number]).to eq phone2.sub_masked_number
        expect(json_body.second[:country]).to eq phone2.country
        expect(json_body.second[:validated_at]).to eq phone2.validated_at
      end

      context 'list of users phone without masking' do
        before do
          Barong::App.config.stub(:api_data_masking_enabled).and_return(false)
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
    end

    describe 'POST /api/v2/resource/phones' do
      let(:do_request) do
        post '/api/v2/resource/phones', params: params, headers: auth_header
      end
      let(:phone_number) { nil }

      let(:params) { { phone_number: phone_number, channel: 'sms' } }

      describe 'errors: ' do
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

          context 'when phone is not verified' do
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
        end
      end

      context 'valid story' do
        before do
          allow(Barong::App.config.twilio_provider).to receive(:send_code).and_return(false)
        end

        context 'when phone is not verified' do
          let(:phone_number) { build(:phone).number }

          it 'assigns a phone to account and send sms' do
            do_request
            expect_body.to eq(message: 'Code was sent successfully via sms')
            expect_status.to eq 201
          end
        end

        context 'when phone is valid' do
          let(:phone_number) { build(:phone).number }

          it 'creates a phone and send code via sms channel' do
            do_request
            expect_body.to eq(message: 'Code was sent successfully via sms')
            expect_status.to eq 201
          end

          it 'creates a phone and send code via call channel' do
            params['channel'] = 'call'

            do_request
            expect_body.to eq(message: 'Code was sent successfully via call')
            expect_status.to eq 201
          end
        end
      end

      context 'when phone is on national format with zero' do
        let(:phone_number) { '+44 07418084106' }
        let(:international_phone) { '447418084106' }

        it 'creates a phone and send sms' do
          allow(Barong::App.config.twilio_provider).to receive(:send_code).and_return(false)

          do_request
          expect_body.to eq(message: 'Code was sent successfully via sms')
          expect_status.to eq 201
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
          allow(Barong::App.config.twilio_provider).to receive(:verify_code?).and_return(false)

          do_request
          expect_body.to eq(errors: ["resource.phone.doesnt_exist"])
          expect_status.to eq 404
        end
      end

      context 'when phone is found in test_user but code is invalid' do
        let!(:phone) { create(:phone, user: test_user) }
        let(:phone_number) { phone.number }

        it 'rendens an error' do
          allow(Barong::App.config.twilio_provider).to receive(:verify_code?).and_return(false)

          do_request
          expect_body.to eq(errors: ["resource.phone.verification_invalid"])
          expect_status.to eq 404
        end
      end

      context 'when phone and code is valid' do
        let(:phone) { create(:phone, user: test_user) }
        let(:phone_number) { phone.number }

        it 'responses with success' do
          allow(Barong::App.config.twilio_provider).to receive(:verify_code?).and_return(true)

          set_level(test_user, 1)
          do_request
          expect_status.to eq 201
          expect(phone.reload.validated_at).to be
          test_user.update_level
          expect(test_user.reload.level).to eq 2
        end
      end
    end
  end

  context 'With Twilio SMS Sender service' do
    let(:phone_number) { phone.number }
    let(:do_request) do
      post '/api/v2/resource/phones', params: params, headers: auth_header
    end
    let(:params) { { phone_number: phone_number, channel: 'sms' } }
    let(:verification_code) { '12345' }

    context 'valid story sms sender service' do
      let(:mock_sms) { Barong::MockSMS }

      before do
        allow(Barong::App.config).to receive(:twilio_provider).and_return(MockPhoneVerifyService)
      end

      context 'when phone is not verified' do
        let(:phone_number) { build(:phone).number }

        it 'assigns a phone to account and send sms' do
          do_request
          expect_body.to eq(message: 'Code was sent successfully via sms')
          expect_status.to eq 201
          expect(mock_sms.messages.last.to).to eq "+#{phone_number}"
        end

        it 'sends a default sms content' do
          do_request
          expect_body.to eq(message: 'Code was sent successfully via sms')
          expect_status.to eq 201
          expect(mock_sms.messages.last.body).to start_with('Your verification code for Barong: ')
        end

        it 'sends a custom message with content before code' do
          allow(Barong::App.config).to receive(:sms_content_template).and_return('Please confirm your phone with the following code: {{code}}')
          do_request
          expect_body.to eq(message: 'Code was sent successfully via sms')
          expect_status.to eq 201
          expect(mock_sms.messages.last.body).to start_with('Please confirm your phone with the following code: ')
        end

        it 'sends a custom message with content after code' do
          allow(Barong::App.config).to receive(:sms_content_template).and_return('{{code}} - this is your confirmation code')
          do_request
          expect_body.to eq(message: 'Code was sent successfully via sms')
          expect_status.to eq 201
          expect(mock_sms.messages.last.body).to end_with(' - this is your confirmation code')
        end

        it 'sends a custom message with code in the midle of the content' do
          allow(Barong::App.config).to receive(:sms_content_template).and_return('Following code: {{code}} should be used for phone confirmation')
          do_request
          expect_body.to eq(message: 'Code was sent successfully via sms')
          expect_status.to eq 201
          expect(mock_sms.messages.last.body).to start_with('Following code: ')
          expect(mock_sms.messages.last.body).to end_with(' should be used for phone confirmation')
        end
      end

      context 'when phone is valid' do
        let(:phone_number) { build(:phone).number }

        it 'creates a phone and send sms' do
          do_request
          expect_body.to eq(message: 'Code was sent successfully via sms')
          expect_status.to eq 201
          expect(mock_sms.messages.last.to).to eq "+#{phone_number}"
        end

        it 'doesnt change code in DB on phone initialize' do
          do_request
          expect_body.to eq(message: 'Code was sent successfully via sms')
          expect_status.to eq 201
          code_after_create = Phone.last.code
          # Phone.last initilazes phone
          code_after_initialize = Phone.last.code
          expect(code_after_create).to eq code_after_initialize
        end
      end
    end

    context 'POST /api/v2/resource/phones/verify' do
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
          expect_body.to eq(errors: ['resource.phone.empty_phone_number', 'resource.phone.empty_verification_code'])
          expect_status.to eq 422
        end
      end

      context 'when phone is invalid' do
        let(:phone_number) { '123' }

        it 'renders an error' do
          do_request
          expect_body.to eq(errors: ['resource.phone.invalid_num'])
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
          expect_body.to eq(errors: ['resource.phone.number_exist'])
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
          expect_body.to eq(errors: ['resource.phone.number_exist'])
          expect_status.to eq 400
        end
      end

      context 'when phone is not found in test_user' do
        let!(:phone) { create(:phone) }
        let(:phone_number) { phone.number }

        it 'rendens an error' do
          do_request
          expect_body.to eq(errors: ['resource.phone.doesnt_exist'])
          expect_status.to eq 404
        end
      end

      context 'when phone is found in test_user but code is invalid still approves because of mock provider' do
        let!(:phone) { create(:phone, user: test_user) }
        let(:phone_number) { phone.number }

        it 'approves phone' do
          do_request

          expect_status.to eq 201
          expect(phone.reload.validated_at).to be
        end
      end

      context 'when phone and code is valid' do
        let(:phone) { create(:phone, user: test_user) }
        let(:phone_number) { phone.number }
        let(:verification_code) { phone.code }

        it 'responses with success' do
          set_level(test_user, 1)
          do_request
          expect_status.to eq 201
          expect(phone.reload.validated_at).to be
          test_user.update_level
          expect(test_user.reload.level).to eq 2
        end
      end
    end
  end
end
