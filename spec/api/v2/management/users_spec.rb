# frozen_string_literal: true

require 'rails_helper'
require 'pry'

describe API::V2::Management::Users, type: :request do
    before do
      defaults_for_management_api_v2_security_configuration!
      management_api_v2_security_configuration.merge! \
        scopes: {
          read_users: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] },
          write_users: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] }
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
    let!(:user) { create(:user, :with_profile) }

    describe 'Show user info' do
      let(:data) do
        {
          scope: :read_users
        }
      end
      let(:expected_attributes) do
        %i[email uid role level otp state profile referral_uid created_at updated_at]
      end
      let(:extended_attributes) do
        %i[email uid role level otp state profile labels phones documents referral_uid created_at updated_at]
      end
      let(:signers) { %i[alex jeff] }

      let(:do_request) do
        post_json '/api/v2/management/users/get',
                  multisig_jwt_management_api_v2({ data: data }, *signers)
      end

      it 'reads user info by uid' do
        data[:uid] = user.uid
        do_request
        expect(response.status).to eq 201
        expect(json_body.keys).to eq expected_attributes
      end

      it 'reads extended user info by uid' do
        data[:uid] = user.uid
        data[:extended] = true
        do_request

        expect(response.status).to eq 201
        expect(json_body.keys).to eq extended_attributes
      end

      it 'reads user info by email' do
        data[:email] = user.email
        do_request
        expect(response.status).to eq 201
        expect(json_body.keys).to eq expected_attributes
      end

      it 'reads extended user info by email' do
        data[:email] = user.email
        data[:extended] = true

        do_request
        expect(response.status).to eq 201
        expect(json_body.keys).to eq extended_attributes
      end

      let!(:phone) do
        create(:phone, validated_at: 1.minutes.ago, user_id: user.id)
      end

      it 'reads user info by user phone' do
        data[:phone_num] = phone.number
        do_request
        expect(response.status).to eq 201
        expect(json_body.keys).to eq expected_attributes
      end

      it 'reads extended user info by user phone' do
        data[:phone_num] = phone.number
        data[:extended] = true

        do_request
        expect(response.status).to eq 201
        expect(json_body.keys).to eq extended_attributes
      end

      it 'allows only one of phone, uid, email' do
        data[:phone_num] = phone.number
        data[:email] = user.email
        data[:uid] = user.uid
        do_request
        expect(response.status).to eq 422
        expect_body.to eq(error: 'uid, email, phone_num are mutually exclusive')
      end

      it 'denies access unless enough signatures are supplied' do
        signers.clear.concat %i[james jeff]
        do_request
        expect(response.status).to eq 401
      end

      it 'denies when uid is not found' do
        data[:uid] = 'invalid'
        do_request
        expect(response.status).to eq 404
      end

      it 'denies when email is not found' do
        data[:email] = 'invalid'
        do_request
        expect(response.status).to eq 404
      end

      it 'denies when email is not found' do
        data[:phone_num] = 'invalid'
        do_request
        expect(response.status).to eq 404
      end

      context 'when data is blank' do
        let(:data) { {} }

        it 'renders errors' do
          do_request
          expect(response.status).to eq 422
          expect_body.to eq(error: 'uid, email, phone_num are missing, exactly one parameter must be provided')
        end
      end
    end

    describe 'Returns array of users as collection' do
      let(:data) do
        {
          scope: :read_users
        }
      end
      let(:signers) { %i[alex jeff] }

      let(:do_request) do
        post_json '/api/v2/management/users/list',
                  multisig_jwt_management_api_v2({ data: data }, *signers)
      end

      context 'users' do
        let!(:test_user) { create(:user, email: 'testa@gmail.com', role: 'admin') }
        let!(:second_user) { create(:user, email: 'testb@gmail.com') }
        let!(:third_user) { create(:user, email: 'testd@gmail.com') }
        let!(:fourth_user) { create(:user, email: 'testc@gmail.com') }

        def validate_fields(user)
          user.attributes.slice('email', 'role', 'level', 'otp', 'state', 'uid')
        end

        include_context 'bearer authentication'

        let(:do_user_request) do
          post_json '/api/v2/management/users/get',
                    multisig_jwt_management_api_v2({ data: data }), headers: auth_header
        end
        it 'denies access for user JWT instead of management signature' do
          do_user_request
          expect(response.status).to eq 401
        end

        it 'denies access unless enough signatures are supplied' do
          signers.clear.concat %i[james jeff]
          do_request
          expect(response.status).to eq 401
        end

        it 'returns list of users' do
          do_request

          users = JSON.parse(response.body)
          expect(User.count).to eq users.count
          expect(validate_fields(User.first)).to eq users.first.except('referral_uid')
          expect(validate_fields(User.second)).to eq users.second.except('referral_uid')
          expect(validate_fields(User.third)).to eq users.third.except('referral_uid')
          expect(validate_fields(User.last)).to eq users.last.except('referral_uid')
        end

        context 'pagination test' do
          let(:users_list_params) do
            {
              scope: :read_users,
              limit: 2
            }
          end

          it 'returns 1st page as default, limit 2 users per page' do
            users_list_params[:page] = 1
            post_json '/api/v2/management/users/list', multisig_jwt_management_api_v2({ data: users_list_params }, *signers), headers: auth_header

            expect(response.headers.fetch('Total')).to eq User.all.count.to_s
            expect(response.headers.fetch('Page')).to eq '1'
            expect(response.headers.fetch('Per-Page')).to eq '2'
          end

          it 'returns 2nd page, limit 2 users per page' do
            users_list_params[:page] = 2
            post_json '/api/v2/management/users/list', multisig_jwt_management_api_v2({ data: users_list_params }, *signers), headers: auth_header

            expect(response.headers.fetch('Total')).to eq User.all.count.to_s
            expect(response.headers.fetch('Page')).to eq '2'
            expect(response.headers.fetch('Per-Page')).to eq '2'
          end
        end

        context 'filtering test' do
          let(:users_list_params) do
            {
              scope: :read_users
            }
          end

          it 'returns filtered list of users when only one filter param given created_at and from' do
            users_list_params[:range] = 'created'
            User.first.update(created_at: 5.hours.ago)
            users_list_params[:from] = 8.hours.ago.to_i
            users_list_params[:to] = 2.hours.ago.to_i

            post_json '/api/v2/management/users/list', multisig_jwt_management_api_v2({ data: users_list_params }, *signers), headers: auth_header

            expect(response.status).to eq 200
            expect(json_body.count).to eq (1)
          end

          it 'returns filtered list of users when only one filter param given updated_at' do
            users_list_params[:range] = 'updated'
            User.first.update(updated_at: 5.hours.ago)
            users_list_params[:from] = 8.hours.ago.to_i
            users_list_params[:to] = 2.hours.ago.to_i

            post_json '/api/v2/management/users/list', multisig_jwt_management_api_v2({ data: users_list_params }, *signers), headers: auth_header

            expect(response.status).to eq 200
            expect(json_body.count).to eq (1)
          end
        end
      end
    end

    describe 'Create an user' do
      let(:signers) { %i[alex jeff] }
      let(:data) { params.merge(scope: :write_users) }

      let(:do_request) do
        post_json '/api/v2/management/users',
                  multisig_jwt_management_api_v2({ data: data }, *signers)
      end

      context 'when password is present' do
        context 'when email and password are valid' do
          let(:params) do
            {
              email: 'valid_email@example.com',
              password: 'Fai5aesoLEcx'
            }
          end
          it 'creates an user' do
            expect { do_request }.to change { User.count }.by(1)
            expect_status_to_eq 201
          end
        end

        context 'when params are blank' do
          let(:params) { {} }

          it 'renders an error' do
            do_request
            expect_status_to_eq 422
            expect_body.to eq(error: 'email is missing, email is empty, password is missing, password is empty')
          end
        end

        context 'when email is bad' do
          let(:params) { { email: 'bad_email', password: 'Password1' } }

          it 'renders an error' do
            expect { do_request }.to_not change { User.count }
            expect_status_to_eq 422
            expect_body.to eq(error: ['Email is invalid','Password is too weak'])
          end
        end

        context 'when password is bad' do
          let(:params) { { email: 'valid_email@example.com', password: 'password' } }

          it 'renders an error' do
            expect { do_request }.to_not change { User.count }
            expect_status_to_eq 422
            expect(json_body[:error].first).to include 'Password does not meet the minimum requirements'
          end
        end
      end
    end

    describe 'Imports an existing user' do
      let(:signers) { %i[alex jeff] }
      let(:data) { params.merge(scope: :write_users) }

      let(:do_request) do
        post_json '/api/v2/management/users/import',
                  multisig_jwt_management_api_v2({ data: data }, *signers)
      end

      let!(:email) { 'valid_email@example.com' }
      let!(:password) { 'Fai5aesoLEcx' }
      let!(:password_digest) do
        User.new(password: password).send(:password_digest)
      end
      let(:params) do
        { email: email, password_digest: password_digest }
      end

      context 'when email and password_hash are valid' do
        it 'creates an user and signs in with credentials' do
          expect { do_request }.to change { User.count }.by(1)
          expect_status_to_eq 201
          expect(json_body).to include(:email, :uid, :role, :level,
                                       :state, :otp, :profile)

          # TODO: Check if imported user is able to login
        end
      end

      context 'when params are blank' do
        let(:params) { {} }

        it 'renders an error' do
          do_request
          expect_status_to_eq 422
          expect_body.to eq(error: 'email is missing, email is empty, password_digest is missing, password_digest is empty')
        end
      end

      context 'when phone is provided' do
        let(:params) do
          {
            email: email,
            password_digest: password_digest,
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
            password_digest: password_digest
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
