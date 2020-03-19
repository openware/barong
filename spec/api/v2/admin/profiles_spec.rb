# frozen_string_literal: true

require 'spec_helper'
describe API::V2::Admin::Profiles do
  include_context 'bearer authentication'

  let!(:create_admin_permission) do
    create :permission,
           role: 'admin'
    create :permission,
           role: 'superadmin'
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
      let!(:member_with_profile) do
        @member = create :user, role: 'member'
        create(:profile, user_id: @member.id, state: 'submitted')
      end

      it 'returns profile' do
        put '/api/v2/admin/profiles', params: request_params.merge(uid: @member.uid), headers: auth_header

        expect(response.status).to eq(200)
        profile = Profile.find_by(request_params)
        expect(profile).to be
        expect(json_body[:state]).to eq('submitted')
        expect(profile.state).to eq('submitted')
        expect(profile.metadata).to be_blank
      end

      let!(:superadmin_with_profile) do
        @user = create :user, role: 'superadmin'
        create(:profile, user_id: @user.id, state: 'submitted')
      end

      it 'return profiles when superadmin updates superadmin' do
        test_user.update!(role: 'superadmin')
        put '/api/v2/admin/profiles', params: request_params.merge(uid: @user.uid, state: 'verified'), headers: auth_header

        expect(response.status).to eq(200)
        profile = Profile.find_by(request_params)
        expect(profile).to be
        expect(json_body[:state]).to eq('verified')
        expect(profile.state).to eq('verified')
        expect(profile.metadata).to be_blank
      end
    end

    context 'unsuccessful response' do
      let!(:superadmin_with_profile) do
        @user = create :user, role: 'superadmin'
        create(:profile, user_id: @user.id, state: 'submitted')
      end

      it 'return error when non-superadmin user updates superadmin' do
        put '/api/v2/admin/profiles', params: request_params.merge(uid: @user.uid), headers: auth_header

        result = JSON.parse(response.body)
        expect(response.code).to eq '422'
        expect(result['errors']).to eq(['admin.profiles.superadmin_change'])
      end

      it 'renders an error when profile doesnt exist' do
        put '/api/v2/admin/profiles', params: { uid: '0' }, headers: auth_header
        expect_status.to eq(404)
        expect_body.to eq(errors: ['admin.profiles.doesnt_exist_or_not_editable'])
      end

      it 'renders an error when profile is not editable' do
        put '/api/v2/admin/profiles', params: request_params.merge(uid: profile3.user.uid), headers: auth_header
        expect_status.to eq(404)
        expect_body.to eq(errors: ['admin.profiles.doesnt_exist_or_not_editable'])
      end
    end

    context 'user with different amount of profile fields' do
      let!(:profile) { create(:profile, user: test_user, last_name: nil, first_name: nil, state: 'submitted') }

      it 'returns partial updated profile' do
        put '/api/v2/admin/profiles', params: request_params.except(:first_name).merge(uid: test_user.uid), headers: auth_header

        expect(response.status).to eq(200)
        profile = Profile.find_by(request_params.except(:first_name))
        expect(profile).to be
        expect(json_body[:state]).to eq('submitted')
        expect(profile.state).to eq('submitted')
        expect(profile.metadata).to be_blank
      end

      it 'returns full updated profile' do
        put '/api/v2/admin/profiles', params: request_params.merge(uid: test_user.uid, state: 'rejected'), headers: auth_header

        expect(response.status).to eq(200)
        profile = Profile.find_by(request_params)
        expect(profile).to be
        expect(json_body[:state]).to eq('rejected')
        expect(profile.state).to eq('rejected')
        expect(profile.metadata).to be_blank
      end
    end
  end
end
