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
  let!(:test_user) { create(:user, role: 'superadmin') }
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
        expect(result.first.keys).to match_array %w[first_name last_name dob address postcode city country state metadata created_at updated_at]
      end

      it 'returns paginated profiles' do
        get '/api/v2/admin/profiles', params: { limit: 1, page: 1 }, headers: auth_header
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(response.headers.fetch('Total')).to eq '5'
        expect(result.size).to eq 1
        expect(result.first['first_name']).to eq profile1.first_name
        expect(result.first['last_name']).to eq profile1.last_name
        expect(result.first['dob']).to eq profile1.dob.to_s

        get '/api/v2/admin/profiles', params: { limit: 1, page: 2 }, headers: auth_header
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(response.headers.fetch('Total')).to eq '5'
        expect(result.size).to eq 1
        expect(result.first['first_name']).to eq profile2.first_name
        expect(result.first['last_name']).to eq profile2.last_name
        expect(result.first['dob']).to eq profile2.dob.to_s

      end
    end
  end

  describe 'POST /api/v2/admin/profiles' do
    let(:user) { create :user }
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
      it 'works correctly' do
        expect { post '/api/v2/admin/profiles', params: request_params.merge(uid: user.uid), headers: auth_header }
          .to change { Profile.count }.by(1)

        expect(response.status).to eq(201)
        expect(json_body.keys).to match_array %i[first_name last_name dob address postcode city country state metadata created_at updated_at]
        expect(json_body[:first_name]).to eq Profile.last.first_name
        expect(json_body[:last_name]).to eq Profile.last.last_name
        expect(json_body[:dob]).to eq Profile.last.dob.to_s
        expect(json_body[:state]).to eq('submitted')
        expect(json_body[:metadata]).to be_blank
        expect(Profile.last.author).to eq(test_user.uid)
      end
    end
  end

  describe 'PUT /api/v2/admin/profiles' do
    context 'successful response' do
      let!(:member_with_profile) do
        @member = create :user, role: 'member'
        create(:profile, user_id: @member.id, state: 'submitted')
      end

      it 'returns profile' do
        put '/api/v2/admin/profiles', params: { uid: @member.uid, state: 'verified' }, headers: auth_header

        expect(response.status).to eq(200)
        profile = @member.profiles.last
        expect(profile).to be
        expect(json_body.keys).to match_array %i[first_name last_name dob address postcode city country state metadata created_at updated_at]
        expect(json_body[:first_name]).to eq profile.first_name
        expect(json_body[:last_name]).to eq profile.last_name
        expect(json_body[:dob]).to eq profile.dob.to_s
        expect(json_body[:state]).to eq('verified')
        expect(profile.state).to eq('verified')
      end

      let!(:superadmin_with_profile) do
        @user = create :user, role: 'superadmin'
        create(:profile, user_id: @user.id, state: 'submitted')
      end

      it 'return profiles when superadmin updates superadmin' do
        test_user.update!(role: 'superadmin')
        put '/api/v2/admin/profiles', params: { uid: @user.uid, state: 'verified' }, headers: auth_header

        expect(response.status).to eq(200)
        profile = @user.profiles.last
        expect(profile).to be
        expect(json_body.keys).to match_array %i[first_name last_name dob address postcode city country state metadata created_at updated_at]
        expect(json_body[:first_name]).to eq profile.first_name
        expect(json_body[:last_name]).to eq profile.last_name
        expect(json_body[:dob]).to eq profile.dob.to_s
        expect(json_body[:state]).to eq('verified')
        expect(profile.state).to eq('verified')
        expect(profile.metadata).to be_blank
      end
    end

    context 'unsuccessful response' do
      let!(:admin_test) { test_user.update(role: 'admin') }

      let!(:superadmin_with_profile) do
        @user = create :user, role: 'superadmin'
        create(:profile, user_id: @user.id, state: 'submitted', author: test_user.uid)

        @user_admin = create :user, role: 'admin'
        create(:profile, user_id: @user_admin.id, state: 'submitted', author: test_user.uid)
      end

      it 'return error when non-superadmin user updates superadmin' do
        put '/api/v2/admin/profiles', params: { uid: @user.uid, state: 'rejected' }, headers: auth_header

        result = JSON.parse(response.body)
        expect(response.code).to eq '422'
        expect(result['errors']).to eq(['admin.profiles.superadmin_change'])
      end

      it 'return error when author is trying to approve himself' do
        allow(Barong::App.config).to receive_messages(profile_double_verification: 'true')

        put '/api/v2/admin/profiles', params: { uid: @user_admin.uid, state: 'rejected' }, headers: auth_header

        result = JSON.parse(response.body)
        expect(response.code).to eq '422'
        expect(result['errors']).to eq(['admin.profiles.second_admin_approval'])
      end

      it 'renders an error when profile doesnt exist' do
        put '/api/v2/admin/profiles', params: { uid: '0', state: 'rejected' }, headers: auth_header
        expect_status.to eq(404)
        expect_body.to eq(errors: ['admin.profiles.doesnt_exist_or_not_editable'])
      end

      it 'renders an error when profile is not editable' do
        put '/api/v2/admin/profiles', params: { uid: profile3.user.uid, state: 'rejected' }, headers: auth_header
        expect_status.to eq(404)
        expect_body.to eq(errors: ['admin.profiles.doesnt_exist_or_not_editable'])
      end
    end

    context 'user with different amount of profile fields' do
      let!(:profile) { create(:profile, user: test_user, last_name: nil, first_name: nil, state: 'submitted') }

      it 'returns partial updated profile' do
        put '/api/v2/admin/profiles', params: { uid: test_user.uid, state: 'rejected' }, headers: auth_header

        expect(response.status).to eq(200)
        profile = test_user.profiles.last
        expect(profile).to be
        expect(json_body.keys).to match_array %i[first_name last_name dob address postcode city country state metadata created_at updated_at]
        expect(json_body[:first_name]).to eq profile.first_name
        expect(json_body[:last_name]).to eq profile.last_name
        expect(json_body[:dob]).to eq profile.dob.to_s
        expect(json_body[:state]).to eq('rejected')
        expect(profile.state).to eq('rejected')
      end

      it 'returns full updated profile' do
        put '/api/v2/admin/profiles', params: { uid: test_user.uid, state: 'rejected' }, headers: auth_header

        expect(response.status).to eq(200)
        profile = test_user.profiles.last
        expect(profile).to be
        expect(json_body.keys).to match_array %i[first_name last_name dob address postcode city country state metadata created_at updated_at]
        expect(json_body[:first_name]).to eq profile.first_name
        expect(json_body[:last_name]).to eq profile.last_name
        expect(json_body[:dob]).to eq profile.dob.to_s
        expect(json_body[:state]).to eq('rejected')
        expect(profile.state).to eq('rejected')
        expect(profile.metadata).to be_blank
      end
    end
  end
end
