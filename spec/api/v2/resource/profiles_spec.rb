# frozen_string_literal: true

describe 'API::V2::Resource::Profiles' do
  include_context 'bearer authentication'
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  let!(:optional_params) do
    {
      metadata: {
        gender: Faker::Creature::Dog.gender,
        place_of_birth: Faker::Address.city
      }.to_json
    }
  end

  describe 'POST /api/v2/resource/profiles' do
    let!(:url) { '/api/v2/resource/profiles' }
    let!(:user_info) { '/api/v2/resource/users/me' }
    let!(:request_params) do
      {
        last_name: Faker::Name.last_name,
        first_name: Faker::Name.first_name,
        dob: Faker::Date.birthday,
        country: Faker::Address.country_code_long,
        city: Faker::Address.city,
        address: Faker::Address.state,
        postcode: Faker::Address.zip_code
      }
    end

    let!(:asian_params) do
      {
        last_name: "국",
        first_name: "채원",
        dob: Faker::Date.birthday,
        country: Faker::Address.country_code_long,
        city: "안산시",
        address: "사직로3길 23",
        postcode: Faker::Address.zip_code
      }
    end

    it 'accept / , ; in address' do
      request_params[:address] = '28/2 Kevin Brook; Miami, USA'
      post url, params: request_params, headers: auth_header
      expect(response.status).to eq(201)
      profile = Profile.find_by(request_params)
      expect(profile).to be
    end

    it 'accept . in address' do
      request_params[:address] = 'Larkin Fork.South, New York/AP'
      post url, params: request_params, headers: auth_header
      expect(response.status).to eq(201)
      profile = Profile.find_by(request_params)
      expect(profile).to be
    end

    it 'accept # \ : " & ( ) in address' do
      request_params[:address] = '28/2 \"Kevin & Brook": (Miami, USA)'
      post url, params: request_params, headers: auth_header
      expect(response.status).to eq(201)
      profile = Profile.find_by(request_params)
      expect(profile).to be
    end

    it "accept ' in address" do
      request_params[:address] = "'Larkin Fork' South New York"
      post url, params: request_params, headers: auth_header
      expect(response.status).to eq(201)
      profile = Profile.find_by(request_params)
      expect(profile).to be
    end

    it 'creates new profile with only required fields' do
      post url, params: request_params, headers: auth_header
      expect(response.status).to eq(201)
      profile = Profile.find_by(request_params)
      expect(profile).to be
      expect(profile.metadata).to be_blank
    end

    it 'creates new profile with corean symbols fields' do
      post url, params: asian_params, headers: auth_header
      expect(response.status).to eq(201)
      profile = Profile.find_by(asian_params)
      expect(profile).to be
    end

    it 'creates new profile with all metadata fields' do
      post url, params: request_params.merge(optional_params), headers: auth_header
      expect(response.status).to eq(201)
      profile = Profile.find_by(request_params)
      expect(profile).to be
      expect(profile.metadata).to eq(optional_params[:metadata])
    end

    it 'renders an error if metadata is not json' do
      post url, params: request_params.merge({ metadata: '{ bar: baz }' }), headers: auth_header
      expect_status_to_eq 422
      expect_body.to eq(errors: ["metadata.invalid_format"])
    end

    context 'create another one profile with state drafted' do
      before do
        post url, params: request_params.merge(optional_params), headers: auth_header
      end

      it 'doesn\'t create new profile' do
        post url, params: request_params.merge(optional_params), headers: auth_header

        result = json_body
        expect(*result[:errors]).to eq('state.exists')
      end
    end

    context 'create another one profile with state submitted' do
      before do
        post url, params: request_params.merge(optional_params, confirm: true), headers: auth_header
      end

      it 'doesn\'t create new profile' do
        post url, params: request_params.merge(optional_params, confirm: true), headers: auth_header

        result = json_body
        expect(*result[:errors]).to eq('state.exists')
      end
    end

    context 'create another one profile with state submitted and drafted' do
      before do
        post url, params: request_params.merge(optional_params, confirm: true), headers: auth_header
      end

      it 'doesn\'t create new profile' do
        post url, params: request_params.merge(optional_params), headers: auth_header

        result = json_body
        expect(*result[:errors]).to eq('state.exists')
      end
    end

    context 'partial creating profile' do
      context 'empty params' do

        before do
          post url, params: {}, headers: auth_header
        end

        subject { Profile.last }

        it { expect(response.status).to eq(201) }

        it { Profile::OPTIONAL_PARAMS.each { |p| expect(json_body[p].blank?).to be_truthy } }

        it { expect(json_body[:state]).to eq('drafted') }

        it { expect(subject).to be }

        it { Profile::OPTIONAL_PARAMS.each { |p| expect(subject.attributes[p].blank?).to be_truthy } }

        it { expect(subject.metadata.blank?).to be_truthy }

        it { expect(subject.state).to eq('drafted') }

        it { expect(subject.user.labels.find_by(key: 'profile').value).to eq('drafted') }
      end

      context 'several params' do

        let(:params) { { last_name: Faker::Name.last_name, first_name: Faker::Name.first_name } }

        subject { Profile.find_by(params) }

        before do
          post url, params: params, headers: auth_header
        end

        it { expect(response.status).to eq(201) }

        it { expect(json_body[:first_name].nil?).to be_falsey }

        it { expect(json_body[:last_name].nil?).to be_falsey }

        it { (Profile::OPTIONAL_PARAMS - params.stringify_keys.keys).each { |p| expect(JSON.parse(response.body)[p].blank?).to be_truthy } }

        it { expect(json_body[:state]).to eq('drafted') }

        it { (Profile::OPTIONAL_PARAMS - params.stringify_keys.keys).each { |p| expect(subject.attributes[p.to_sym].blank?).to be_truthy } }

        it { expect(subject.metadata.blank?).to be_truthy }

        it { expect(subject.state).to eq('drafted') }

        it { expect(subject.user.labels.find_by(key: :profile).value).to eq('drafted') }
      end

      context 'several params with profile confirmation' do

        let(:params) { { last_name: Faker::Name.last_name, first_name: Faker::Name.first_name } }

        subject { Profile.find_by(params) }

        before do
          post url, params: params.merge(confirm: true), headers: auth_header
        end

        it { expect(response.status).to eq(201) }

        it { expect(json_body[:first_name].nil?).to be_falsey }

        it { expect(json_body[:last_name].nil?).to be_falsey }

        it { (Profile::OPTIONAL_PARAMS - params.stringify_keys.keys).each { |p| expect(JSON.parse(response.body)[p].blank?).to be_truthy } }

        it { expect(json_body[:state]).to eq('submitted') }

        it { (Profile::OPTIONAL_PARAMS - params.stringify_keys.keys).each { |p| expect(subject.attributes[p.to_sym].blank?).to be_truthy } }

        it { expect(subject.metadata.blank?).to be_truthy }

        it { expect(subject.state).to eq('submitted') }

        it { expect(subject.user.labels.find_by(key: :profile).value).to eq('submitted') }
      end

      context 'full profile params' do

        subject { Profile.find_by(request_params) }

        before do
          post url, params: request_params, headers: auth_header
        end

        it { expect(response.status).to eq(201) }

        it { request_params.keys.each { |p| expect(json_body[p].present?).to be_truthy } }

        it { expect(json_body[:state]).to eq('drafted') }

        it { request_params.stringify_keys.keys.each { |p| expect(subject.attributes[p].present?).to be_truthy } }

        it { expect(subject.metadata.blank?).to be_truthy }

        it { expect(subject.state).to eq('drafted') }

        it { expect(subject.user.labels.find_by(key: 'profile').value).to eq('drafted') }
      end
    end
  end

  describe 'GET /api/v2/resource/profiles/me' do
    let!(:url) { '/api/v2/resource/profiles/me' }
    let!(:request_params) do
      {
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        dob: Faker::Date.birthday,
        address: Faker::Address.state,
        postcode: Faker::Address.zip_code,
        city: Faker::Address.city,
        country: Faker::Address.country_code_long
      }
    end

    it 'returns user profile data with metadata' do
      post '/api/v2/resource/profiles', params: request_params.merge(optional_params),
                               headers: auth_header
      expect(response.status).to eq(201)

      get url, headers: auth_header
      expect(response.status).to eq(200)
      expected_json = request_params.merge(state: 'drafted').merge(optional_params).to_json
      expect(JSON.parse(response.body)[0]).to eq(JSON.parse(expected_json))
    end
  end

  context 'event API behavior' do
    let!(:url) { '/api/v2/resource/profiles' }
    let!(:request_params) do
      {
        last_name: Faker::Name.last_name,
        first_name: Faker::Name.first_name,
        dob: Faker::Date.birthday,
        country: Faker::Address.country_code_long,
        city: Faker::Address.city,
        address: Faker::Address.state,
        postcode: Faker::Address.zip_code
      }
    end

    before do
      allow(EventAPI).to receive(:notify)
    end

    it 'receive model.profile.created notify' do
      expect(EventAPI).to receive(:notify).ordered.with('model.user.created', hash_including(:record))
      expect(EventAPI).to receive(:notify).ordered.with('model.profile.created', hash_including(:record))

      post url, params: request_params, headers: auth_header
    end

    it 'receive model.profile.created notify with user and profile params' do
      expect(EventAPI).to receive(:notify).ordered.with('model.user.created', hash_including(:record))
      expect(EventAPI).to receive(:notify).ordered.with(
        'model.profile.created',
        hash_including(
          record: {
            user: anything,
            address: anything,
            city: anything,
            country: anything,
            created_at: anything,
            updated_at: anything,
            dob: anything,
            first_name: anything,
            last_name: anything,
            postcode: anything
          }
        )
      )

      post url, params: request_params, headers: auth_header
    end
  end

  describe 'PUT /api/v2/resource/profiles' do
    let!(:url) { '/api/v2/resource/profiles' }
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

    context 'user without profile' do
      it 'renders an error when profile doesnt exist' do
        put url, params: request_params, headers: auth_header

        expect_status.to eq(404)
        expect_body.to eq(errors: ['resource.profile.doesnt_exist_or_not_editable'])
      end
    end

    context 'user with profile' do
      let!(:profile) { create(:profile, user: test_user)}

      it 'returns submitted profile' do
        put url, params: request_params.merge(confirm: true), headers: auth_header

        expect(response.status).to eq(200)
        profile = Profile.find_by(request_params)
        expect(profile).to be
        expect(json_body[:state]).to eq('submitted')
        expect(profile.state).to eq('submitted')
        expect(profile.metadata).to be_blank
      end
    end

    context 'user with partial profile' do
      let!(:profile) { create(:profile, user: test_user, last_name: nil, first_name: nil) }

      it 'returns partial profile' do
        put url, params: request_params.except(:first_name), headers: auth_header

        expect(response.status).to eq(200)
        profile = Profile.find_by(request_params.except(:first_name))
        expect(profile).to be
        expect(json_body[:state]).to eq('drafted')
        expect(profile.state).to eq('drafted')
        expect(profile.metadata).to be_blank
      end

      it 'returns completed profile' do
        put url, params: request_params, headers: auth_header

        expect(response.status).to eq(200)
        profile = Profile.find_by(request_params)
        expect(profile).to be
        expect(json_body[:state]).to eq('drafted')
        expect(profile.state).to eq('drafted')
        expect(profile.metadata).to be_blank
      end
    end
  end
end
