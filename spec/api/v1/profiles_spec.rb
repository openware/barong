# frozen_string_literal: true

ENV['PROFILE_METADATA'] = 'gender place_of_birth'

describe 'Api::V1::Profiles' do
  include_context 'doorkeeper authentication'

  describe 'POST /api/v1/profiles' do
    let!(:url) { '/api/v1/profiles' }
    let!(:request_params) do
      {
        last_name: Faker::Name.last_name,
        first_name: Faker::Name.first_name,
        dob: Faker::Date.birthday,
        country: Faker::Address.country,
        city: Faker::Address.city,
        address: Faker::Address.street_address,
        postcode: Faker::Address.zip_code
      }
    end

    let!(:optional_params) do
      {
        gender: Faker::Dog.gender,
        place_of_birth: Faker::Address.city
      }
    end

    it 'throws an error, cause some of the required params are absent' do
      post url, params: request_params.except(:dob), headers: auth_header
      expect(response.body).to eq('{"error":"dob is missing"}')
      expect(response.status).to eq(400)

      post url, params: request_params.except(:first_name), headers: auth_header
      expect(response.body).to eq('{"error":"first_name is missing"}')
      expect(response.status).to eq(400)

      post url, headers: auth_header
      expect(response.body).to eq('{"error":"first_name is missing, last_name is missing, dob is missing, address is missing, postcode is missing, city is missing, country is missing"}')
      expect(response.status).to eq(400)
    end

    it 'creates new profile with only required fields' do
      post url, params: request_params, headers: auth_header
      expect(response.status).to eq(201)
      profile = Profile.find_by(request_params)
      expect(profile).to_not be_nil
      expect(profile.gender).to be_nil
      expect(profile.place_of_birth).to be_nil
    end

    it 'creates new profile with all metadata fields' do
      post url, params: request_params.merge(optional_params), headers: auth_header
      expect(response.status).to eq(201)
      profile = Profile.find_by(request_params)
      expect(profile).to_not be_nil
      expect(profile.gender).to eq(optional_params[:gender])
      expect(profile.place_of_birth).to eq(optional_params[:place_of_birth])
    end

    it 'creates new profile with not all metadata fields' do
      post url, params: request_params.merge(optional_params).except(:place_of_birth), headers: auth_header
      expect(response.status).to eq(201)
      profile = Profile.find_by(request_params)
      expect(profile).to_not be_nil
      expect(profile.gender).to eq(optional_params[:gender])
      expect(profile.place_of_birth).to be_nil
    end
  end
  describe 'GET /api/v1/profiles' do
    let!(:url) { '/api/v1/profiles' }
    let!(:request_params) do
      {
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        dob: Faker::Date.birthday,
        address: Faker::Address.street_address,
        postcode: Faker::Address.zip_code,
        city: Faker::Address.city,
        country: Faker::Address.country
      }
    end

    let!(:optional_params) do
      {
        gender: Faker::Dog.gender,
        place_of_birth: Faker::Address.city
      }
    end

    it 'returns user profile data with metadata' do
      post url, params: request_params.merge(optional_params), headers: auth_header
      expect(response.status).to eq(201)

      get url, headers: auth_header
      expect(response.status).to eq(200)
      expected_json = request_params.merge(state: Account.last.state, metadata: optional_params).to_json
      expect(response.body).to eq(expected_json)
    end
  end
end
