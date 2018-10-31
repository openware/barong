# frozen_string_literal: true

describe ManagementAPI::V1::Accounts, type: :request do
  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
      scopes: {
        read_accounts: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] },
        write_accounts: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] }
      }
  end

  let!(:account) { create(:account, :with_profile) }

  describe 'Show account info' do
    let(:data) do
      {
        uid: account.uid,
        scope: :read_accounts
      }
    end
    let(:expected_attributes) do
      %i[email uid role level otp_enabled state profile created_at updated_at]
    end
    let(:signers) { %i[alex jeff] }

    let(:do_request) do
      post_json '/management_api/v1/accounts/get',
                multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    it 'reads account info' do
      do_request
      expect(response.status).to eq 201
      expect(json_body.keys).to eq expected_attributes
    end

    it 'denies access unless enough signatures are supplied' do
      signers.clear.concat %i[james jeff]
      do_request
      expect(response.status).to eq 401
    end

    it 'denies when account is not found' do
      data[:uid] = 'invalid'
      do_request
      expect(response.status).to eq 404
    end

    context 'when data is blank' do
      let(:data) { {} }

      it 'renders errors' do
        do_request
        expect(response.status).to eq 422
        expect_body.to eq(error: 'UID is missing, UID is empty')
      end
    end
  end

  describe 'Create an account' do
    let(:signers) { %i[alex jeff] }
    let(:data) { params.merge(scope: :write_accounts) }

    let(:do_request) do
      post_json '/management_api/v1/accounts',
                multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    context 'when password is present' do
      context 'when email and password are valid' do
        let(:params) do
          {
            email: 'valid_email@example.com',
            password: 'Fai5aeso'
          }
        end
        let!(:application) { create :doorkeeper_application }

        it 'creates an account' do
          expect { do_request }.to change { Account.count }.by(1)
          expect_status_to_eq 201
        end
      end

      context 'when params are blank' do
        let(:params) { {} }

        it 'renders an error' do
          do_request
          expect_status_to_eq 422
          expect_body.to eq(error: 'Email is missing, Email is empty, Password is missing, Password is empty')
        end
      end

      context 'when email is bad' do
        let(:params) { { email: 'bad_email', password: 'Password1' } }

        it 'renders an error' do
          expect { do_request }.to_not change { Account.count }
          expect_status_to_eq 422
          expect_body.to eq(error: ['Email is invalid', 'Password has previously appeared in a data breach and should never be used. Please choose something harder to guess.'])
        end
      end

      context 'when password is bad' do
        let(:params) { { email: 'valid_email@example.com', password: 'password' } }

        it 'renders an error' do
          expect { do_request }.to_not change { Account.count }
          expect_status_to_eq 422
          expect(json_body[:error].first).to include 'Password does not meet the minimum system requirements'
        end
      end
    end
  end

  describe 'Imports an existing account' do
    let(:signers) { %i[alex jeff] }
    let(:data) { params.merge(scope: :write_accounts) }

    let(:do_request) do
      post_json '/management_api/v1/accounts/import',
                multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let!(:email) { 'valid_email@example.com' }
    let!(:password) { 'Password1' }
    let!(:password_hash) do
      Account.new.send(:password_digest, password)
    end
    let(:params) do
      { email: email, password_hash: password_hash }
    end

    context 'when email and password_hash are valid' do
      let!(:application) { create :doorkeeper_application }

      it 'creates an account and signs in with credentials' do
        expect { do_request }.to change { Account.count }.by(1)
        expect_status_to_eq 201
        expect(json_body).to include(:email, :uid, :role, :level,
                                     :state, :otp_enabled, :profile)

        post '/api/v1/sessions', params: {
          application_id: application.uid,
          email: email,
          password: password
        }
        expect_status.to eq(201)
      end
    end

    context 'when params are blank' do
      let(:params) { {} }

      it 'renders an error' do
        do_request
        expect_status_to_eq 422
        expect_body.to eq(error: 'Email is missing, Email is empty, Password Hash is missing, Password Hash is empty')
      end
    end

    context 'when phone is provided' do
      let(:params) do
        {
          email: email,
          password_hash: password_hash,
          phone: phone
        }
      end

      context 'when phone is valid' do
        let(:phone) { build(:phone).number }

        it 'creates a phone' do
          expect { do_request }.to change { Phone.count }.by(1)
          expect_status_to_eq 201
        end
      end

      context 'when phone is invalid' do
        let(:phone) { '12345' }

        it 'renders an error' do
          expect { do_request }.to_not change { Phone.count }
          expect_status_to_eq 422
          expect(json_body[:error]).to eq ['Number is invalid']
        end
      end
    end

    context 'when profile params are provided' do
      let(:params) do
        {
          email: email,
          password_hash: password_hash
        }.merge(profile_params)
      end

      context 'when params are valid' do
        let(:profile_params) do
          {
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name,
            dob: Faker::Date.birthday,
            country: Faker::Address.country_code_long,
            city: Faker::Address.city,
            address: Faker::Address.street_address,
            postcode: Faker::Address.zip_code
          }
        end

        it 'creates a profile' do
          expect { do_request }.to change { Profile.count }.by(1)
          expect_status_to_eq 201
        end
      end

      context 'when postcode is not provided' do
        let(:profile_params) do
          {
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name,
            dob: Faker::Date.birthday,
            country: Faker::Address.country_code_long,
            city: Faker::Address.city,
            address: Faker::Address.street_address
          }
        end

        it 'does not create a profile' do
          expect { do_request }.to_not change { Profile.count }
          expect_status_to_eq 201
        end
      end

      context 'when params are invalid' do
        let(:profile_params) do
          {
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name,
            dob: Faker::Date.birthday,
            country: 'a',
            city: Faker::Address.city,
            address: Faker::Address.street_address,
            postcode: Faker::Address.zip_code
          }
        end

        it 'renders an error' do
          expect { do_request }.to_not change { Profile.count }
          expect_status_to_eq 422
          expect(json_body[:error]).to eq ['Country must have alpha2 or alpha3 format']
        end
      end
    end
  end
end
