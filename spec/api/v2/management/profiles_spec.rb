# frozen_string_literal: true

require 'rails_helper'

describe API::V2::Management::Profiles, type: :request do
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

  let(:signers) { %i[alex jeff] }
  let(:data) { params.merge(scope: :write_users) }

  let(:do_request) do
    post_json '/api/v2/management/profiles',
              multisig_jwt_management_api_v2({ data: data }, *signers)
  end

  context 'when profile params are provided' do
    let(:params) do
      profile_params
    end

    context 'when params are valid' do
      let(:user) { create :user }
      let(:profile_params) do
        {
          uid: user.uid,
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          dob: Faker::Date.birthday,
          country: Faker::Address.country_code_long,
          city: Faker::Address.city,
          address: Faker::Address.state,
          postcode: Faker::Address.zip_code
        }
      end

      it 'creates a profile' do
        expect { do_request }.to change { Profile.count }.by(1)
        expect_status_to_eq 201

        result = JSON.parse(response.body)
        expect(result['profiles'][0]['state']).to eq 'drafted'
        expect(result['profiles'][0]['last_name']).to eq profile_params[:last_name]
        expect(result['profiles'][0]['dob']).to eq profile_params[:dob].to_s
      end
    end

    context 'when postcode is not provided' do
      let(:user) { create :user }
      let(:profile_params) do
        {
          uid: user.uid,
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          dob: Faker::Date.birthday,
          country: Faker::Address.country_code_long,
          city: Faker::Address.city,
          address: Faker::Address.state
        }
      end

      it 'create a profile' do
        expect { do_request }.to change { Profile.count }
        expect_status_to_eq 201
        result = JSON.parse(response.body)
        expect(result['profiles'][0]['state']).to eq 'drafted'
        expect(result['profiles'][0]['last_name']).to eq profile_params[:last_name]
        expect(result['profiles'][0]['dob']).to eq profile_params[:dob].to_s
      end
    end

    context 'when profile state is provided' do
      let(:user) { create :user }
      let(:profile_params) do
        {
          uid: user.uid,
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          dob: Faker::Date.birthday,
          country: Faker::Address.country_code_long,
          city: Faker::Address.city,
          address: Faker::Address.state,
          state: 'rejected'
        }
      end

      it 'create a profile' do
        expect { do_request }.to change { Profile.count }
        expect_status_to_eq 201
        result = JSON.parse(response.body)
        expect(result['profiles'][0]['state']).to eq 'rejected'
        expect(result['profiles'][0]['last_name']).to eq profile_params[:last_name]
        expect(result['profiles'][0]['dob']).to eq profile_params[:dob].to_s
      end
    end

    context 'when params are invalid' do
      let(:user) { create :user }
      let(:profile_params) do
        {
          uid: user.uid,
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          dob: Faker::Date.birthday,
          country: 'a',
          city: Faker::Address.city,
          address: Faker::Address.state,
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
