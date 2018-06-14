# frozen_string_literal: true

describe 'Api::V1::Profiles' do
  include_context 'doorkeeper authentication'

  let!(:optional_params) do
    {
      metadata: {
        gender: Faker::Dog.gender,
        place_of_birth: Faker::Address.city
      }
    }
  end

  describe 'POST /api/v1/profiles' do
    let!(:url) { '/api/v1/profiles' }
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

    it 'throws an error, cause some of the required params are absent' do
      post url, params: request_params.except(:dob), headers: auth_header
      expect_body.to eq(error: 'Birthday is missing')
      expect(response.status).to eq(400)

      post url, params: request_params.except(:first_name), headers: auth_header
      expect_body.to eq(error: 'First Name is missing')
      expect(response.status).to eq(400)

      post url, headers: auth_header
      expect_body.to eq(error: 'First Name is missing, Last Name is missing, Birthday is missing, Address is missing, Postcode is missing, City is missing, Country is missing')
      expect(response.status).to eq(400)
    end

    it 'creates new profile with only required fields' do
      post url, params: request_params, headers: auth_header
      expect(response.status).to eq(201)
      profile = Profile.find_by(request_params)
      expect(profile).to be
      expect(profile.metadata).to be_blank
    end

    it 'creates new profile with all metadata fields' do
      post url, params: request_params.merge(optional_params), headers: auth_header
      expect(response.status).to eq(201)
      profile = Profile.find_by(request_params)
      expect(profile).to be
      expect(profile.metadata.symbolize_keys).to eq(optional_params[:metadata])
    end

    it 'renders an error when field is invalid' do
      post url, params: request_params.merge(first_name: 'A'), headers: auth_header
      expect_status.to eq(422)
      expect_body.to eq(error: 'First name is too short (minimum is 2 characters)')
    end
  end

  describe 'GET /api/v1/profiles/me' do
    let!(:url) { '/api/v1/profiles/me' }
    let!(:request_params) do
      {
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        dob: Faker::Date.birthday,
        address: Faker::Address.street_address,
        postcode: Faker::Address.zip_code,
        city: Faker::Address.city,
        country: Faker::Address.country_code_long
      }
    end

    it 'returns user profile data with metadata' do
      post '/api/v1/profiles', params: request_params.merge(optional_params),
                               headers: auth_header
      expect(response.status).to eq(201)

      get url, headers: auth_header
      expect(response.status).to eq(200)
      expected_json = request_params.merge(optional_params).to_json
      expect(response.body).to eq(expected_json)
    end
  end
end
