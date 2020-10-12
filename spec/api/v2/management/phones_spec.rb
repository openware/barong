# frozen_string_literal: true

describe API::V2::Management::Phones, type: :request do
  before do
    defaults_for_management_api_v2_security_configuration!
    management_api_v2_security_configuration.merge! \
      scopes: {
        write_phones:  { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] },
      }
  end
  let!(:create_admin_permission) do
    create :permission,
           role: 'admin'
  end
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  let!(:user) { create(:user) }

  describe 'POST /phones' do
    let(:signers) { %i[alex jeff] }
    let(:data) { params.merge(scope: :write_phones) }

    let(:do_request) do
      post_json '/api/v2/management/phones',
                multisig_jwt_management_api_v2({ data: data }, *signers)
    end

    let(:params) do
      phone_params
    end

    context 'valid request' do
      let(:phone_params) do
        {
          uid: user.uid,
          number: '12345678911'
        }
      end

      it 'creates a phone' do
        expect { do_request }.to change { Phone.count }.by(1)
        expect_status_to_eq 201

        result = JSON.parse(response.body)
        expect(result['country']).to eq 'US'
        expect(result['number']).to eq phone_params[:number]
      end
    end

    context 'invalid request' do
      context 'when phone is invalid' do
        let(:phone_params) do
          {
            uid: user.uid,
            number: '123'
          }
        end

        it 'renders an error' do
          do_request
          expect_body.to eq(error: "management.phone.invalid_num")
          expect_status.to eq 400
        end
      end

      context 'when phone is missing' do
        let(:phone_params) do
          {
            uid: user.uid
          }
        end

        it 'renders an error' do
          do_request
          expect_status.to eq 422
          expect_body.to eq(error: 'number is missing, number is empty')
        end
      end

      context 'when phone is already exists' do
        let!(:phone) do
          create(:phone, validated_at: validated_at)
        end

        let(:phone_params) do
          {
            uid: user.uid,
            number: phone.number
          }
        end

        context 'when phone verified' do
          let(:validated_at) { 1.minutes.ago }

          it 'renders an error' do
            do_request
            expect_body.to eq(error: 'management.phone.number_exist')
            expect_status.to eq 400
          end
        end

        context 'when phone verified but number is not sanitized' do
          let(:validated_at) { 1.minutes.ago }
          let(:phone_params) do
            {
              uid: user.uid,
              number: "++#{phone.number}"
            }
          end

          it 'renders an error' do
            do_request
            expect_body.to eq(error: 'management.phone.number_exist')
            expect_status.to eq 400
          end
        end
      end

      context 'when phone exists on international format' do
        let(:phone_params) do
          {
            uid: user.uid,
            number: '+44 07418084106'
          }
        end
        let(:international_phone) { '447418084106' }
        let!(:phone) do
          create(:phone, validated_at: 1.minute.ago, number: international_phone)
        end

        it 'renders an error' do
          do_request
          expect_body.to eq(error: "management.phone.number_exist")
          expect_status.to eq 400
        end
      end

      context 'when phone exists for current user' do
        let!(:phone) { create(:phone, number: '447418084106', user_id: user.id)}
        let(:phone_params) do
          {
            uid: user.uid,
            number: '447418084106'
          }
        end

        it 'renders an error' do
          do_request
          expect_body.to eq(error: "management.phone.exists")
          expect_status.to eq 400
        end
      end
    end
  end
end
