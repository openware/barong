# frozen_string_literal: true

require 'spec_helper'
describe API::V2::Admin::Profiles do
  include_context 'bearer authentication'

  let!(:create_admin_permission) do
    create :permission,
           role: 'admin'
  end

  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end

  let!(:profile1) { create(:profile) }
  let!(:profile2) { create(:profile) }
  let!(:profile3) { create(:profile) }
  let!(:profile4) { create(:profile) }
  let!(:profile5) { create(:profile) }

  describe 'GET /api/v2/admin/profiles' do
    context 'successful response' do
      it 'returns all profiles' do
        get '/api/v2/admin/profiles', headers: auth_header

        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result.count).to eq(Profile.count)
      end

      it 'returns paginated profiles' do
        get '/api/v2/admin/profiles', params: { limit: 1, page: 1 }, headers: auth_header
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(response.headers.fetch('Total')).to eq '5'
        expect(result.size).to eq 1
        expect(result.first['first_name']).to eq profile1.first_name

        get '/api/v2/admin/profiles', params: { limit: 1, page: 2 }, headers: auth_header
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(response.headers.fetch('Total')).to eq '5'
        expect(result.size).to eq 1
        expect(result.first['first_name']).to eq profile2.first_name
      end
    end
  end

  describe 'DELETE /api/v2/admin/profiles' do
    context 'successful response' do
      let(:do_request) { delete '/api/v2/admin/profiles', params: { id: profile1.id }, headers: auth_header }

      it 'delete profile' do
        expect { do_request }.to change { Profile.count }.by(-1)

        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result['first_name']).to eq profile1.first_name
      end
    end

    context 'unsuccessful response' do
      it 'return error while profiles doesnt exist' do
        delete '/api/v2/admin/profiles', params: { id: 0 }, headers: auth_header

        result = JSON.parse(response.body)
        expect(response.code).to eq '404'
        expect(result['errors']).to eq(['admin.profiles.doesnt_exist'])
      end
    end
  end

  describe 'PUT /api/v2/admin/profiles' do
    let!(:request_params) do
      {
        last_name: Faker::Name.last_name,
        first_name: Faker::Name.first_name,
        dob: Faker::Date.birthday,
        country: Faker::Address.country_code_long,
        city: Faker::Address.city,
        address: Faker::Address.street_address,
        postcode: Faker::Address.zip_code
      }
    end

    context 'successful response' do
      it 'returns completed profile' do
        put '/api/v2/admin/profiles', params: request_params.merge(id: profile2.id), headers: auth_header

        expect(response.status).to eq(200)
        profile = Profile.find_by(request_params)
        expect(profile).to be
        expect(json_body[:state]).to eq('completed')
        expect(profile.state).to eq('completed')
        expect(profile.metadata).to be_blank
      end
    end

    context 'user with partial profile' do
      let!(:profile) { create(:profile, user: test_user, last_name: nil, first_name: nil) }

      it 'returns partial profile' do
        put '/api/v2/admin/profiles', params: request_params.except(:first_name).merge(id: profile.id), headers: auth_header

        expect(response.status).to eq(200)
        profile = Profile.find_by(request_params.except(:first_name))
        expect(profile).to be
        expect(json_body[:state]).to eq('partial')
        expect(profile.state).to eq('partial')
        expect(profile.metadata).to be_blank
      end

      it 'returns completed profile' do
        put '/api/v2/admin/profiles', params: request_params.merge(id: profile.id), headers: auth_header

        expect(response.status).to eq(200)
        profile = Profile.find_by(request_params)
        expect(profile).to be
        expect(json_body[:state]).to eq('completed')
        expect(profile.state).to eq('completed')
        expect(profile.metadata).to be_blank
      end
    end

    context 'unccessful response' do
      it 'renders an error when profile doesnt exist' do
        put '/api/v2/admin/profiles', params: { id: 0 }, headers: auth_header

        expect_status.to eq(404)
        expect_body.to eq(errors: ['admin.profiles.doesnt_exist'])
      end
    end
  end
end
