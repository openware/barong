# frozen_string_literal: true

describe 'Api::V2::Resource::DataStorage' do
  include_context 'bearer authentication'
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end

  describe 'POST /api/v2/resource/data_storage' do
    let(:url) { '/api/v2/resource/data_storage' }

    context 'successful creation' do
      let(:valid_params) do
        {
          title: 'personal',
          data: { wife_last_name: Faker::Name.last_name, wife_first_name: Faker::Name.first_name }.to_json
        }
      end

      it 'creates data_storage record' do
        expect { post url, params: valid_params, headers: auth_header }.to change { DataStorage.count }.by(1)
        expect(response.status).to eq(201)
      end

      it 'creates a label when recording data_storage' do
        expect { post url, params: valid_params, headers: auth_header }.to change { Label.count }.by(1)
        expect(response.status).to eq(201)
        expect(test_user.labels.find_by(key: valid_params[:title])).not_to be_nil
      end
    end

    context 'errors' do
      let(:non_json_data_params) { { title: 'personal', data: 'My name is John Doe. Hello, World!' } }
      let(:non_whitelisted_params) { { title: 'family_info', data: { wife_first_name: Faker::Name.first_name }.to_json } }
      let(:blacklisted_params) { { title: 'document', data: { approved: true }.to_json } }

      it 'doesnt accept non-json data' do
        expect { post url, params: non_json_data_params, headers: auth_header }.not_to change { DataStorage.count }

        expect(response.status).to eq(422)
        expect(json_body).to eq({errors: ['data.invalid_format']})
      end

      it 'doesnt accept non-whitelisted title' do
        expect { post url, params: non_whitelisted_params, headers: auth_header }.not_to change { DataStorage.count }
        expect(response.status).to eq(422)
        expect(json_body).to eq({errors: ['title.inclusion']})
      end

      it 'doesnt accept blacklisted title' do
        expect { post url, params: blacklisted_params, headers: auth_header }.not_to change { DataStorage.count }
        expect(response.status).to eq(422)
        expect(json_body).to eq({errors: ['title.inclusion', 'title.exclusion']})
      end
    end
  end
end
