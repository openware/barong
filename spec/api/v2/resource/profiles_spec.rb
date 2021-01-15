# frozen_string_literal: true

describe 'API::V2::Resource::Profiles' do
  before { allow(Barong::App.config).to receive_messages(kyc_provider: 'local') }

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
    describe 'KYC verification' do
      let!(:request_params) do
        {
          last_name: Faker::Name.last_name,
          first_name: Faker::Name.first_name,
          dob: Faker::Date.birthday,
          country: Faker::Address.country_code,
          city: Faker::Address.city,
          address: Faker::Address.state,
          postcode: Faker::Address.zip_code
        }
      end
      let!(:url) { '/api/v2/resource/profiles' }

      it 'triggers KycService' do
        expect(KycService).to receive(:profile_step)

        post url, params: request_params, headers: auth_header
        expect(response.status).to eq(201)
      end

      context 'Local verification' do
        before { allow(Barong::App.config).to receive_messages(kyc_provider: 'local') }

        it 'adds a label for first verification' do
          expect(test_user.labels).to eq([])
          post url, params: request_params, headers: auth_header
          expect(test_user.reload.labels.count).to eq(1)
          expect(test_user.reload.labels.first.key).to eq('profile')
          expect(test_user.reload.labels.first.value).to eq('drafted')
        end

        it 'doesnt trigger KYCAID worker' do
          expect(KycService).to receive(:profile_step)
          expect(KYC::Kycaid::ApplicantWorker).not_to receive(:perform_async)

          post url, params: request_params, headers: auth_header
          expect(response.status).to eq(201)
        end

        it 'updates label on re-submit' do
          expect(test_user.labels).to eq([])
          post url, params: request_params, headers: auth_header
          expect(test_user.reload.labels.count).to eq(1)
          expect(test_user.reload.labels.first.key).to eq('profile')
          expect(test_user.reload.labels.first.value).to eq('drafted')

          put url, params: request_params.merge(confirm: true), headers: auth_header
          expect(test_user.reload.labels.count).to eq(1)
          expect(test_user.reload.labels.first.key).to eq('profile')
          expect(test_user.reload.labels.first.value).to eq('submitted')
        end
      end

      context 'KYCAID verification' do
        before { allow(Barong::App.config).to receive_messages(kyc_provider: 'kycaid') }

        it 'adds a label for first verification' do
          expect(test_user.labels).to eq([])
          post url, params: request_params, headers: auth_header
          expect(test_user.reload.labels.count).to eq(1)
          expect(test_user.reload.labels.first.key).to eq('profile')
          expect(test_user.reload.labels.first.value).to eq('drafted')
        end

        it 'updates label on re-submit' do
          expect(test_user.labels).to eq([])
          post url, params: request_params, headers: auth_header
          expect(test_user.reload.labels.count).to eq(1)
          expect(test_user.reload.labels.first.key).to eq('profile')
          expect(test_user.reload.labels.first.value).to eq('drafted')

          put url, params: request_params.merge(confirm: true), headers: auth_header
          expect(test_user.reload.labels.count).to eq(1)
          expect(test_user.reload.labels.first.key).to eq('profile')
          expect(test_user.reload.labels.first.value).to eq('submitted')
        end

        it 'triggers KYCAID worker on submitted state' do
          expect(KYC::Kycaid::ApplicantWorker).to receive(:perform_async)
          post url, params: request_params.merge(confirm: true), headers: auth_header
          expect(response.status).to eq(201)
        end

        it 'doesnt trigger KYCAID worker on drafted state' do
          expect(KYC::Kycaid::ApplicantWorker).not_to receive(:perform_async)
          post url, params: request_params, headers: auth_header
          expect(response.status).to eq(201)
        end

        it 'doesnt trigger KYCAID worker on rejected state' do
          post url, params: request_params.merge(confirm: true), headers: auth_header
          expect(response.status).to eq(201)

          expect(KYC::Kycaid::ApplicantWorker).not_to receive(:perform_async)
          test_user.reload.profiles.last.update(state: 'rejected')
        end

        it 'doesnt trigger KYCAID worker on verified state' do
          post url, params: request_params.merge(confirm: true), headers: auth_header
          expect(response.status).to eq(201)

          expect(KYC::Kycaid::ApplicantWorker).not_to receive(:perform_async)
          test_user.reload.profiles.last.update(state: 'verified')
        end
      end
    end

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
      expect { post url, params: request_params, headers: auth_header }
        .to change { Profile.count }.by (1)
      expect(response.status).to eq(201)
      res = json_body
      expect(res[:address]).to eq request_params[:address]
    end

    it 'accept . in address' do
      request_params[:address] = 'Larkin Fork.South, New York/AP'
      expect { post url, params: request_params, headers: auth_header }
        .to change { Profile.count }.by (1)
      expect(response.status).to eq(201)
      res = json_body
      expect(res[:address]).to eq request_params[:address]
    end

    it 'accept # ~ \ : " & ( ) in address' do
      request_params[:address] = '28~1/2 \"Kevin & Brook": (Miami, USA)'
      expect { post url, params: request_params, headers: auth_header }
        .to change { Profile.count }.by (1)
      expect(response.status).to eq(201)
      res = json_body
      expect(res[:address]).to eq request_params[:address]
    end

    it "accept ' in address" do
      request_params[:address] = "'Larkin Fork' South New York"
      expect { post url, params: request_params, headers: auth_header }
        .to change { Profile.count }.by (1)
      expect(response.status).to eq(201)
      res = json_body
      expect(res[:address]).to eq request_params[:address]
    end

    it "accept – in address" do
      request_params[:address] = "'Larkin–Fork' South New York"
      expect { post url, params: request_params, headers: auth_header }
        .to change { Profile.count }.by (1)
      expect(response.status).to eq(201)
      res = json_body
      expect(res[:address]).to eq request_params[:address]
    end

    it "doesn't accept @ in address" do
      request_params[:address] = "'Larkin–Fork' @South New York"
      expect { post url, params: request_params, headers: auth_header }
        .not_to change { Profile.count }
      expect(response.status).to eq(422)
    end

    it 'accept . in city' do
      request_params[:city] = 'St. Petersburg'
      expect { post url, params: request_params, headers: auth_header }
        .to change { Profile.count }.by (1)
      expect(response.status).to eq(201)
      res = json_body
      expect(res[:city]).to eq request_params[:city]
    end

    it 'accept dash in city' do
      request_params[:city] = 'Hubli–Dharwad'
      expect { post url, params: request_params, headers: auth_header }
        .to change { Profile.count }.by (1)
      expect(response.status).to eq(201)
      res = json_body
      expect(res[:city]).to eq request_params[:city]
    end

    it 'accept hyphen in city' do
      request_params[:city] = 'Hubli-Dharwad'
      expect { post url, params: request_params, headers: auth_header }
        .to change { Profile.count }.by (1)
      expect(response.status).to eq(201)
      res = json_body
      expect(res[:city]).to eq request_params[:city]
    end

    it 'accept \' in city' do
      request_params[:city] = 'Cava de\' Tirreni'
      expect { post url, params: request_params, headers: auth_header }
        .to change { Profile.count }.by (1)
      expect(response.status).to eq(201)
      res = json_body
      expect(res[:city]).to eq request_params[:city]
    end

    it "doesn't accept # in city" do
      request_params[:city] = 'Cava de\' #Tirreni'
      expect { post url, params: request_params, headers: auth_header }
        .not_to change { Profile.count }
      expect(response.status).to eq(422)
    end

    it "doesn't accept @ in city" do
      request_params[:city] = 'Cava de\' @Tirreni'
      expect { post url, params: request_params, headers: auth_header }
        .not_to change { Profile.count }
      expect(response.status).to eq(422)
    end

    it 'creates new profile with only required fields' do
      expect { post url, params: request_params, headers: auth_header }
        .to change { Profile.count }.by (1)
      expect(response.status).to eq(201)

      res = json_body
      expect(res[:last_name]).to eq request_params[:last_name].sub(/(?<=\A.{1})(.*)/) { |match| '*' * match.length }
      expect(res[:first_name]).to eq request_params[:first_name]
      expect(res[:dob]).to eq request_params[:dob].to_s.sub(/(?<=\A.{8})(.*)/) { |match| '*' * match.length }
      expect(res[:country]).to eq request_params[:country]
      expect(res[:city]).to eq request_params[:city]
      expect(res[:address]).to eq request_params[:address]
      expect(res[:postcode]).to eq request_params[:postcode]
      expect(res[:metadata]).to be_blank
    end

    it 'creates new profile with only required fields without masking' do
      Barong::App.config.stub(:api_data_masking_enabled).and_return(false)
      expect { post url, params: request_params, headers: auth_header }
        .to change { Profile.count }.by (1)
      expect(response.status).to eq(201)

      res = json_body
      expect(res[:last_name]).to eq request_params[:last_name]
      expect(res[:first_name]).to eq request_params[:first_name]
      expect(res[:dob]).to eq request_params[:dob].to_s
      expect(res[:country]).to eq request_params[:country]
      expect(res[:city]).to eq request_params[:city]
      expect(res[:address]).to eq request_params[:address]
      expect(res[:postcode]).to eq request_params[:postcode]
      expect(res[:metadata]).to be_blank
    end

    it 'creates new profile with corean symbols fields' do
      expect { post url, params: asian_params, headers: auth_header }
        .to change { Profile.count }.by (1)
      expect(response.status).to eq(201)

      res = json_body

      expect(res[:last_name]).to eq asian_params[:last_name]
      expect(res[:first_name]).to eq asian_params[:first_name]
      expect(res[:dob]).to eq asian_params[:dob].to_s.sub(/(?<=\A.{8})(.*)/) { |match| '*' * match.length }
      expect(res[:country]).to eq asian_params[:country]
      expect(res[:city]).to eq asian_params[:city]
      expect(res[:address]).to eq asian_params[:address]
      expect(res[:postcode]).to eq asian_params[:postcode]
      expect(res[:metadata]).to be_blank
    end

    it 'creates new profile with all metadata fields' do
      expect { post url, params: request_params.merge(optional_params), headers: auth_header }
        .to change { Profile.count }.by (1)
      expect(response.status).to eq(201)

      res = json_body
      expect(res[:metadata]).to eq(optional_params[:metadata])
    end

    it 'renders an error if metadata is not json' do
      expect { post url, params: request_params.merge({ metadata: '{ bar: baz }' }), headers: auth_header }
        .not_to change { Profile.count }
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

        it 'returns profile' do
          expect { post url, params: {}, headers: auth_header }
            .to change { Profile.count }.by (1)

          expect(response.status).to eq(201)
          expect(json_body[:state]).to eq('drafted')
          expect(json_body[:metadata].blank?).to be_truthy
          Profile::OPTIONAL_PARAMS.each { |p|
            expect(json_body[p].blank?).to be_truthy
          }
          Profile::OPTIONAL_PARAMS.each { |p|
            expect(json_body.with_indifferent_access[p].blank?).to be_truthy
          }
          expect(Profile.last.user.labels.find_by(key: 'profile').value).to eq('drafted')
        end
      end

      context 'several params' do
        let(:params) { { last_name: Faker::Name.last_name, first_name: Faker::Name.first_name } }

        it 'returns profile' do
          expect { post url, params: params, headers: auth_header }
            .to change { Profile.count }.by (1)

          expect(response.status).to eq(201)
          expect(json_body[:first_name].nil?).to be_falsey
          expect(json_body[:last_name].nil?).to be_falsey
          expect(json_body[:state]).to eq('drafted')
          expect(json_body[:metadata].blank?).to be_truthy
          (Profile::OPTIONAL_PARAMS - params.stringify_keys.keys).each { |p|
            expect(json_body.with_indifferent_access[p].blank?).to be_truthy
          }
          expect(Profile.last.user.labels.find_by(key: :profile).value).to eq('drafted')
        end
      end

      context 'several params with profile confirmation' do
        let(:params) { { last_name: Faker::Name.last_name, first_name: Faker::Name.first_name } }

        it 'returns profile' do
          expect { post url, params: params.merge(confirm: true), headers: auth_header }
            .to change { Profile.count }.by (1)

          expect(response.status).to eq(201)
          expect(json_body[:first_name].nil?).to be_falsey
          expect(json_body[:last_name].nil?).to be_falsey
          expect(json_body[:state]).to eq('submitted')
          expect(json_body[:metadata].blank?).to be_truthy
          (Profile::OPTIONAL_PARAMS - params.stringify_keys.keys).each { |p|
            expect(json_body.with_indifferent_access[p].blank?).to be_truthy
          }
          expect(Profile.last.user.labels.find_by(key: :profile).value).to eq('submitted')
        end
      end

      context 'full profile params' do
        it 'returns profile' do
          expect { post url, params: request_params, headers: auth_header }
            .to change { Profile.count }.by (1)

          expect(response.status).to eq(201)
          expect(json_body[:state]).to eq('drafted')
          expect(json_body[:metadata].blank?).to be_truthy
          request_params.keys.each { |p|
            expect(json_body[p].present?).to be_truthy
          }
          expect(Profile.last.user.labels.find_by(key: 'profile').value).to eq('drafted')
        end
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
      last_name = request_params[:last_name].sub(/(?<=\A.{1})(.*)/) { |match| '*' * match.length }
      dob = request_params[:dob].to_s.sub(/(?<=\A.{8})(.*)/) { |match| '*' * match.length }
      expected_json = request_params.merge(state: 'drafted', last_name: last_name,dob: dob).merge(optional_params).to_json
      expect(JSON.parse(response.body)[0].except('created_at', 'updated_at')).to eq(JSON.parse(expected_json))
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
        expect { put url, params: request_params.merge(confirm: true), headers: auth_header }
          .not_to change { Profile.count }

        expect(response.status).to eq(200)
        expect(json_body[:state]).to eq('submitted')
        expect(profile[:metadata]).to be_blank
      end
    end

    context 'user with partial profile' do
      let!(:profile) { create(:profile, user: test_user, last_name: nil, first_name: nil) }

      it 'returns partial profile' do
        expect { put url, params: request_params.except(:first_name), headers: auth_header }
          .not_to change { Profile.count }

        expect(response.status).to eq(200)
        expect(json_body[:state]).to eq('drafted')
        expect(json_body[:metadata]).to be_blank
      end

      it 'returns completed profile' do
        expect { put url, params: request_params, headers: auth_header }
          .not_to change { Profile.count }

        expect(response.status).to eq(200)
        expect(json_body[:state]).to eq('drafted')
        expect(json_body[:metadata]).to be_blank
      end
    end
  end
end
