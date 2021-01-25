# frozen_string_literal: true

require 'spec_helper'
describe API::V2::Admin::Users do
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

  let(:experimental_user) { create(:user, :with_document_phone_profile, state: "pending") }

  describe 'GET /api/v2/admin/users' do
    let(:do_request) { get '/api/v2/admin/users', headers: auth_header }

    context 'admin user' do
      let!(:test_user) { create(:user, email: 'testa@gmail.com', role: 'admin') }
      let!(:second_user) { create(:user, email: 'testb@gmail.com', level: 2, state: 'active') }
      let!(:third_user) { create(:user, email: 'testd@gmail.com', level: 2, state: 'pending') }
      let!(:fourth_user) { create(:user, email: 'testc@gmail.com', level: 1, state: 'active') }

      let(:params) { {} }
      let(:do_search_request) { get '/api/v2/admin/users', headers: auth_header, params: params }

      def validate_fields(user)
        user.attributes.slice('email', 'username', 'role', 'level', 'otp', 'state', 'uid', 'data').symbolize_keys
      end

      it 'returns list of users' do
        do_request

        expect(json_body.first.keys).to match_array %i[email username uid role level otp state referral_uid data]
        expect(User.count).to eq json_body.count
        expect(validate_fields(User.first)).to eq json_body.first.except(:referral_uid)
        expect(validate_fields(User.second)).to eq json_body.second.except(:referral_uid)
        expect(validate_fields(User.third)).to eq json_body.third.except(:referral_uid)
        expect(validate_fields(User.fourth)).to eq json_body.fourth.except(:referral_uid)

        expect(json_body.first.keys).to_not include(:profiles)

        expect(response.headers.fetch('Total')).to eq User.all.count.to_s
        expect(response.headers.fetch('Page')).to eq '1'
        expect(response.headers.fetch('Per-Page')).to eq '100'
      end

      it 'returns list of users in ASC order' do
        params[:ordering] = 'asc'
        params[:order_by] = 'id'
        do_search_request

        expect(json_body.first.keys).to match_array %i[email username uid role level otp state referral_uid data]
        expect(User.count).to eq json_body.count
        expect(validate_fields(User.first)).to eq json_body.first.except(:referral_uid)
        expect(validate_fields(User.second)).to eq json_body.second.except(:referral_uid)
        expect(validate_fields(User.third)).to eq json_body.third.except(:referral_uid)
        expect(validate_fields(User.fourth)).to eq json_body.fourth.except(:referral_uid)
      end

      it 'returns list of users in DESC order' do
        params[:ordering] = 'desc'
        params[:order_by] = 'id'
        do_search_request

        expect(json_body.first.keys).to match_array %i[email username uid role level otp state referral_uid data]
        expect(User.count).to eq json_body.count
        expect(validate_fields(User.first)).to eq json_body.fifth.except(:referral_uid)
        expect(validate_fields(User.second)).to eq json_body.fourth.except(:referral_uid)
        expect(validate_fields(User.third)).to eq json_body.third.except(:referral_uid)
        expect(validate_fields(User.fourth)).to eq json_body.second.except(:referral_uid)
      end

      it 'returns error if invalid ordering' do
        params[:ordering] = 'resc'
        params[:order_by] = 'id'
        do_search_request

        expect(response.status).to eq 422
        expect(response.body).to eq "{\"errors\":[\"user.ordering.invalid_ordering\"]}"
      end

      it 'returns error when user attribute doesnt exist' do
        params[:ordering] = 'asc'
        params[:order_by] = 'algorithm'
        do_search_request

        expect(response.status).to eq 422
        expect(response.body).to eq "{\"errors\":[\"user.ordering.invalid_attribute\"]}"
      end

      it 'returns filtered list of users when only one filter param given created_at and from' do
        params[:range] = 'created'
        test_user.update(created_at: 1.day.ago)
        params[:from] = fourth_user.created_at.to_i
        do_search_request

        expect(response.status).to eq 200
        expect(json_body.first.keys).to match_array %i[email username uid role level otp state referral_uid data]
        expect(json_body).not_to include(test_user)
      end

      it 'returns filtered list of users when only one filter param given (user attribute) level' do
        params[:level] = 2
        do_search_request
        expect(response.status).to eq 200
        expect(json_body.first.keys).to match_array %i[email username uid role level otp state referral_uid data]
        expect(json_body.count).to eq User.where(level: 2).count
      end

      it 'returns filtered list of users when only one filter param given (user attribute) state' do
        params[:state] = 'active'
        do_search_request
        expect(response.status).to eq 200
        expect(json_body.first.keys).to match_array %i[email username uid role level otp state referral_uid data]
        expect(json_body.count).to eq User.where(state: 'active').count
      end

      it 'returns filtered list of users when several params given (user attribute) : state and level' do
        params[:level] = 2
        params[:state] = 'active'
        do_search_request
        expect(response.status).to eq 200
        expect(json_body.first.keys).to match_array %i[email username uid role level otp state referral_uid data]
        expect(json_body.count).to eq User.where(level: 2, state: 'active').count
      end

      let!(:user_with_profiles) do
        user = create :user, email: 'peatio@barong.com'
        create :profile, user_id: user.id, first_name: 'peatio', last_name: 'barong', country: 'us', state: 'rejected'
        create :profile, user_id: user.id, first_name: 'peatio', last_name: 'barong', country: 'us', state: 'rejected'
      end

      it 'returns only uniq set of users' do
        user_with_profiles

        do_search_request
        expect(response.status).to eq 200
        expect(json_body.first.keys).to match_array %i[email username uid role level otp state referral_uid data]
        expect(json_body.count).to eq User.count
      end

      it 'returns filtered list of users when only one filter param given (profile attribute) first_name' do
        params[:first_name] = 'peatio'
        do_search_request
        expect(response.status).to eq 200
        expect(json_body.first.keys).to match_array %i[email username uid role level otp state referral_uid data]
      end

      it 'returns filtered list of users when several params given (profile attribute) : first_name and country' do
        params[:first_name] = 'peatio'
        params[:last_name] = 'barong'
        params[:country] = 'barong'
        do_search_request
        expect(response.status).to eq 200
      end

      context 'extended params' do
        let(:extended_params) { { extended: true } }
        let(:do_extended_info_request) { get '/api/v2/admin/users', headers: auth_header, params: extended_params }
        let!(:user) { create(:user, :with_profile) }

        it 'returns list of users with full info' do
          do_extended_info_request
          expect(User.count).to eq json_body.count

          expect(json_body.first.keys).to include(:profiles)

          expect(response.headers.fetch('Total')).to eq User.all.count.to_s
          expect(response.headers.fetch('Page')).to eq '1'
          expect(response.headers.fetch('Per-Page')).to eq '100'
          expect(json_body.first.keys).to match_array %i[email username uid role level otp state data profiles referral_uid created_at updated_at]
          expect(json_body.last[:profiles][0][:first_name]).to eq user.profiles.first.first_name
          expect(json_body.last[:profiles][0][:last_name]).to eq user.profiles.first.last_name
          expect(json_body.last[:profiles][0][:address]).to eq user.profiles.first.address
          expect(json_body.last[:profiles][0][:dob]).to eq user.profiles.first.dob.to_s
        end
      end

      it 'returns list of users (ASC ordered) in search' do
        params[:email] = 'testa@gmail.com'
        do_search_request

        expect(json_body.count).to eq 1
        expect(json_body.first.keys).to match_array %i[email username uid role level otp state referral_uid data]
        expect(json_body[0][:email]).to eq 'testa@gmail.com'
      end

      it 'returns all users (ASC ordered) in search req if field is not in the list' do
        params.clear
        params[:field] = 'bazz'
        do_search_request

        expect(json_body.count).to eq User.all.count

        expect_status.to eq(200)
        expect(json_body.first.keys).to match_array %i[email username uid role level otp state referral_uid data]
      end

      context 'pagination test' do
        it 'returns 1st page as default, limit 2 users per page' do
          get '/api/v2/admin/users', headers: auth_header, params: {
            limit: 2
          }
          expect(validate_fields(User.first)).to eq json_body.first.except(:referral_uid)
          expect(validate_fields(User.second)).to eq json_body.second.except(:referral_uid)

          expect(response.headers.fetch('Total')).to eq User.all.count.to_s
          expect(response.headers.fetch('Page')).to eq '1'
          expect(response.headers.fetch('Per-Page')).to eq '2'
          expect(json_body.first.keys).to match_array %i[email username uid role level otp state referral_uid data]
        end

        it 'returns 2nd page, limit 2 users per page' do
          get '/api/v2/admin/users', headers: auth_header, params: {
            limit: 2,
            page: 2
          }
          expect(validate_fields(User.third)).to eq json_body.first.except(:referral_uid)
          expect(validate_fields(User.fourth)).to eq json_body.second.except(:referral_uid)
          expect(response.headers.fetch('Total')).to eq User.all.count.to_s
          expect(response.headers.fetch('Page')).to eq '2'
          expect(response.headers.fetch('Per-Page')).to eq '2'
          expect(json_body.first.keys).to match_array %i[email username uid role level otp state referral_uid data]
        end
      end
    end
  end

  describe 'PUT /api/v2/admin/users' do
    let(:do_request) { put '/api/v2/admin/users', headers: auth_header }

    context 'admin user' do
      let(:test_user) { create(:user, role: "admin") }
      let(:user_with_api_keys) { create(:user, state: "active", otp: true) }
      let!(:api_key1) { create(:api_key, key_holder_account: user_with_api_keys) }
      let!(:api_key2) { create(:api_key, key_holder_account: user_with_api_keys) }

      it 'renders error if uid is misssing' do
        put '/api/v2/admin/users', headers: auth_header, params: {
          state: 'active'
        }
        expect(response.status).to eq 422
        expect(response.body).to eq "{\"errors\":[\"admin.user.missing_uid\",\"admin.user.empty_uid\"]}"
      end

      let!(:superadmin) { create(:user, role: 'superadmin') }

      it 'renders error when non-superadmin user updates superadmin' do
        put '/api/v2/admin/users', headers: auth_header, params: {
          uid: superadmin.uid,
          state: 'active'
        }

        result = JSON.parse(response.body)
        expect(response.code).to eq '422'
        expect(result['errors']).to eq(['admin.user.superadmin_change'])
      end

      it 'renders error if state is misssing' do
        put '/api/v2/admin/users', headers: auth_header, params: {
          uid: experimental_user.uid
        }
        expect(response.status).to eq 422
        expect(response.body).to eq "{\"errors\":[\"admin.user.one_of_state_otp_email\"]}"
      end

      it 'renders error if otp is misssing' do
        put '/api/v2/admin/users', headers: auth_header, params: {
          uid: experimental_user.uid
        }
        expect(response.status).to eq 422
        expect(response.body).to eq "{\"errors\":[\"admin.user.one_of_state_otp_email\"]}"
      end

      it 'renders error if role is misssing' do
        put '/api/v2/admin/users', headers: auth_header, params: {
          uid: experimental_user.uid
        }
        expect(response.status).to eq 422
        expect(response.body).to eq "{\"errors\":[\"admin.user.one_of_state_otp_email\"]}"
      end

      it 'renders error if uid is incorrect' do
        put '/api/v2/admin/users', headers: auth_header, params: {
          uid: 'asdasdasd',
          state: 'active'
        }
        expect(response.status).to eq 404
        expect(response.body).to eq "{\"errors\":[\"admin.user.doesnt_exist\"]}"
      end

      it 'sets state to active' do
        put '/api/v2/admin/users', headers: auth_header, params: {
          uid: experimental_user.uid,
          state: 'active'
        }
        expect(response.status).to eq 200
        expect(experimental_user.reload.state).to eq 'active'
      end

      it 'sets otp to false' do
        experimental_user.update(otp: 'true')
        experimental_user.labels.create(key: :otp, value: :enabled, scope: :private)
        put '/api/v2/admin/users', headers: auth_header, params: {
          uid: experimental_user.uid,
          otp: 'false'
        }
        expect(response.status).to eq 200
        expect(experimental_user.reload.otp).to eq false
        expect(experimental_user.reload.labels.find_by(key: :otp, scope: :private)).to eq nil
      end

      it 'sets role to admin' do
        post '/api/v2/admin/users/role', headers: auth_header, params: {
          uid: experimental_user.uid,
          role: 'admin'
        }
        expect(response.status).to eq 200
        expect(experimental_user.reload.role).to eq 'admin'
      end

      it 'renders error when state is the same' do
        put '/api/v2/admin/users', headers: auth_header, params: {
          uid: experimental_user.uid,
          state: 'pending'
        }
        expect(response.status).to eq 422
        expect(response.body).to eq "{\"errors\":[\"admin.user.state_no_change\"]}"
      end

      it 'doesnt disable api keys for enabling otp' do
        put '/api/v2/admin/users', headers: auth_header, params: {
          uid: user_with_api_keys.uid,
          otp: true
        }
        expect(api_key1.reload.state).to eq 'active'
        expect(api_key2.reload.state).to eq 'active'
      end

      it 'doesnt disable api keys for activating user' do
        put '/api/v2/admin/users', headers: auth_header, params: {
          uid: user_with_api_keys.uid,
          state: 'active'
        }
        expect(api_key1.reload.state).to eq 'active'
        expect(api_key2.reload.state).to eq 'active'
      end

      it 'disables api_keys when state changes' do
        put '/api/v2/admin/users', headers: auth_header, params: {
          uid: user_with_api_keys.uid,
          state: 'banned'
        }
        expect(api_key1.reload.state).to eq 'inactive'
        expect(api_key2.reload.state).to eq 'inactive'
      end

      it 'disables api_keys when sets otp to false' do
        put '/api/v2/admin/users', headers: auth_header, params: {
          uid: user_with_api_keys.uid,
          otp: false
        }
        expect(api_key1.reload.state).to eq 'inactive'
        expect(api_key2.reload.state).to eq 'inactive'
      end
    end

    context 'superadmin user' do
      let(:do_request) { put '/api/v2/admin/users', params: params, headers: auth_header }
      let(:test_user) { create(:user, role: "superadmin") }
  
      let(:params) do
        {
          uid: experimental_user.uid,
          email: new_email,
        }
      end
      let(:new_email) { '' }
      context "when email is blank" do
        it 'renders an error' do
          do_request
          expect(response.status).to eq(422)
          expect_body.to eq(errors: ["admin.user.empty_email"])
        end
      end
      context 'when email is invalid' do
        let(:new_email) { 'bad_format' }
        it 'renders an error' do
          do_request
          expect_status_to_eq 422
          expect_body.to eq(errors: ["email.invalid"])
        end
      end
      context 'when email is valid' do
        let(:new_email) { 'valid.email@gmail.com' }
        it 'change an email' do
          do_request          
          expect_status_to_eq 200
          expect(experimental_user.reload.email).to eq 'valid.email@gmail.com'
        end
      end
      context 'when non-superadmin user updates email' do
        let(:test_user) { create(:user, role: "admin") }
        let(:new_email) { 'valid.email@gmail.com' }
        it 'renders an error' do
          do_request
          expect_status_to_eq 422
          expect_body.to eq(errors: ["superadmin.user.update_email"])
        end
      end
    end
  end

  describe 'Get /api/v2/admin/users/:uid' do
    let(:do_request) { get '/api/v2/admin/users/' + experimental_user.uid, headers: auth_header }

    context 'admin user' do
      let(:test_user) { create(:user, :with_document_phone_profile, role: "admin") }

      it 'renders error if uid is invalid' do
        get '/api/v2/admin/users/asdasdsad', headers: auth_header
        expect(response.status).to eq 404
        expect(response.body).to eq "{\"errors\":[\"admin.user.doesnt_exist\"]}"
      end

      it 'returns user info' do
        do_request

        expect(response.status).to eq 200

        expect(json_body.keys).to match_array %i[email username uid role level otp state data profiles labels phones documents data_storages comments referral_uid created_at updated_at]
        expect(json_body[:uid]).to eq experimental_user.uid
        expect(json_body[:role]).to eq experimental_user.role
        expect(json_body[:email]).to eq experimental_user.email
        expect(json_body[:level]).to eq experimental_user.level
        expect(json_body[:otp]).to eq experimental_user.otp
        expect(json_body[:state]).to eq experimental_user.state
        expect(json_body[:profiles][0][:first_name]).to eq experimental_user.profiles[0].first_name
        expect(json_body[:profiles][0][:last_name]).to eq experimental_user.profiles[0].last_name
        expect(json_body[:profiles][0][:address]).to eq experimental_user.profiles[0].address
        expect(json_body[:profiles][0][:dob]).to eq experimental_user.profiles[0].dob.to_s
        expect(json_body[:documents][0][:doc_number]).to eq experimental_user.documents[0].doc_number
        expect(json_body[:phones][0][:number]).to eq experimental_user.phones[0].number
      end
    end
  end

  describe 'GET /api/v2/admin/labels/list' do
    let(:do_request) { get '/api/v2/admin/users/labels/list', headers: auth_header }
    let!(:test_user) { create(:user, role: 'admin') }

    context 'it returns array of labels attributes' do
      let(:create_labels) { 10.times do create(:label, scope: 'private') end }

      it 'acts as expected' do
        create_labels
        do_request
        labels_from_db = Label.where(scope: 'private').group(:key, :value).size
        expect(response.body).to eq(labels_from_db.to_json)
        expect(response.status).to eq 200
      end
    end

    context 'no labels in database' do
      it 'returns empty array' do
        do_request

        expect(response.body).to eq '{}'
        expect(response.status).to eq 200
      end
    end
  end

  describe 'POST /api/v2/admin/labels' do

    let(:do_request) { post '/api/v2/admin/users/labels', headers: auth_header }

    context 'admin user' do
      let(:test_user) { create(:user, role: 'admin') }

      it 'renders error when uid is missing' do
        post '/api/v2/admin/users/labels', headers: auth_header, params: {
          key: 'email',
          value: 'vedified'
        }
        expect(response.status).to eq 422
        expect(response.body).to eq "{\"errors\":[\"admin.user.missing_uid\",\"admin.user.empty_uid\"]}"
      end

      let!(:superadmin) { create(:user, role: 'superadmin') }

      it 'renders error when non-superadmin user updates superadmin' do
        post '/api/v2/admin/users/labels', headers: auth_header, params: {
          uid: superadmin.uid,
          key: 'email',
          value: 'vedified'
        }

        result = JSON.parse(response.body)
        expect(response.code).to eq '422'
        expect(result['errors']).to eq(['admin.user.superadmin_change'])
      end

      it 'renders error when key is missing' do
        post '/api/v2/admin/users/labels', headers: auth_header, params: {
          uid: experimental_user.uid,
          value: 'vedified'
        }
        expect(response.status).to eq 422
        expect(response.body).to eq "{\"errors\":[\"admin.user.missing_key\",\"admin.user.empty_key\"]}"
      end

      it 'renders error when description is empty' do
        post '/api/v2/admin/users/labels', headers: auth_header, params: {
          uid: experimental_user.uid,
          key: 'email',
          value: 'vedified',
          description: ''
        }
        expect(response.status).to eq 422
        expect(response.body).to eq "{\"errors\":[\"admin.user.empty_description\"]}"
      end

      it 'renders error when value is missing' do
        post '/api/v2/admin/users/labels', headers: auth_header, params: {
          uid: experimental_user.uid,
          key: 'email'
        }
        expect(response.status).to eq 422
        expect(response.body).to eq "{\"errors\":[\"admin.user.missing_value\",\"admin.user.empty_value\"]}"
      end

      it 'renders error when uid is invalid' do
        post '/api/v2/admin/users/labels', headers: auth_header, params: {
          uid: 'asdasds',
          key: 'email',
          value: 'verified'
        }
        expect(response.status).to eq 404
        expect(response.body).to eq "{\"errors\":[\"admin.user.doesnt_exist\"]}"
      end

      it 'adds label with default public scope and description' do
        post '/api/v2/admin/users/labels', headers: auth_header, params: {
          uid: experimental_user.uid,
          key: 'email',
          value: 'verified',
          description: 'public label test'
        }
        updated_user = experimental_user.reload
        added_label = updated_user.labels.last
        expect(response.status).to eq 200
        expect(added_label.key).to eq 'email'
        expect(added_label.value).to eq 'verified'
        expect(added_label.scope).to eq 'public'
        expect(added_label.description).to eq 'public label test'
      end

      it 'adds label with private scope' do
        post '/api/v2/admin/users/labels', headers: auth_header, params: {
          uid: experimental_user.uid,
          key: 'email',
          value: 'verified',
          scope: 'private'
        }
        updated_user = experimental_user.reload
        added_label = updated_user.labels.last
        expect(response.status).to eq 200
        expect(added_label.key).to eq 'email'
        expect(added_label.value).to eq 'verified'
        expect(added_label.scope).to eq 'private'
      end
    end
  end

  describe 'DELETE /api/v2/admin/labels' do
    let(:do_request) { delete '/api/v2/admin/users/labels', headers: auth_header }

    context 'admin user' do
      let(:test_user) { create(:user, role: 'admin') }
      let(:add_label) {
        post '/api/v2/admin/users/labels', headers: auth_header, params: {
          uid: experimental_user.uid,
          key: 'email',
          value: 'verified',
          description: 'experimental QA signup'
        }
      }

      it 'renders error when uid is missing' do
        delete '/api/v2/admin/users/labels', headers: auth_header, params: {
          key: 'email',
          scope: 'public'
        }
        expect(response.status).to eq 422
        expect(response.body).to eq "{\"errors\":[\"admin.user.missing_uid\",\"admin.user.empty_uid\"]}"
      end

      it 'renders error when key is missing' do
        delete '/api/v2/admin/users/labels', headers: auth_header, params: {
          uid: experimental_user.uid,
          scope: 'public'
        }
        expect(response.status).to eq 422
        expect(response.body).to eq "{\"errors\":[\"admin.user.missing_key\",\"admin.user.empty_key\"]}"
      end

      it 'renders error when scope is missing' do
        delete '/api/v2/admin/users/labels', headers: auth_header, params: {
          key: 'email',
          uid: experimental_user.uid
        }
        expect(response.status).to eq 422
        expect(response.body).to eq "{\"errors\":[\"admin.user.missing_scope\",\"admin.user.empty_scope\"]}"
      end

      it 'renders error when uid is invalid' do
        delete '/api/v2/admin/users/labels', headers: auth_header, params: {
          key: 'email',
          uid: 'asdasdasdsadas',
          scope: 'public'
        }
        expect(response.status).to eq 404
        expect(response.body).to eq "{\"errors\":[\"admin.user.doesnt_exist\"]}"
      end

      it 'renders error when label does not exist' do
        delete '/api/v2/admin/users/labels', headers: auth_header, params: {
          key: 'email',
          uid: experimental_user.uid,
          scope: 'public'
        }
        expect(response.status).to eq 404
        expect(response.body).to eq "{\"errors\":[\"admin.label.doesnt_exist\"]}"
      end

      it 'deletes label' do
        add_label
        delete '/api/v2/admin/users/labels', headers: auth_header, params: {
          key: 'email',
          uid: experimental_user.uid,
          scope: 'public'
        }
        experimental_user.reload
        expect(response.status).to eq 200
        expect(experimental_user.labels.count).to eq 1
      end
    end
  end

  describe 'POST /api/v2/admin/users/labels/update' do
    let(:user) { create(:user, role: 'admin') }
    let!(:create_superadmin_permission) { create(:permission, role: 'superadmin', action: 'accept', verb: 'get') }
    let!(:test_user) { create(:user, role: 'superadmin') }
    let(:data) do
      {
        uid: user.uid,
        key: 'phone',
        value: 'verified',
        scope: 'private',
        description: 'experimental phone verification'
      }
    end
    let(:do_request) do
      post '/api/v2/admin/users/labels/update', headers: auth_header, params: data
    end

    context 'with default replace policy(true)' do
      it 'creates a label' do
        expect(user.labels.find_by(key: 'phone')).to eq(nil)

        do_request
        expect(response.status).to eq 200
        expect(user.labels.find_by(key: 'phone')).not_to eq(nil)
      end

      context 'when data is incomplete and description is empty' do
        let(:data) do
          {
            uid: user.uid,
            key: 'phone',
            scope: 'private',
            description: ''
          }
        end

        it 'receive an error' do
          expect(user.labels.find_by(key: 'phone')).to eq(nil)

          do_request
          expect(response.status).to eq 422
          expect(response.body).to eq "{\"errors\":[\"admin.user.missing_value\",\"admin.user.empty_value\",\"admin.user.empty_description\"]}"
          expect(user.labels.find_by(key: 'phone')).to eq(nil)
        end
      end
    end

    context 'with false replace policy' do
      let(:data) do
        {
          uid: user.uid,
          key: 'phone',
          value: 'verified',
          scope: 'private',
          replace: false
        }
      end

      it 'receives an error' do
        expect(user.labels.find_by(key: 'phone')).to eq(nil)

        do_request
        expect(response.status).to eq 404
        expect(user.labels.find_by(key: 'phone')).to eq(nil)
        expect(response.body).to eq "{\"errors\":[\"admin.label.doesnt_exist\"]}"
      end
    end
  end

  describe 'GET /api/v2/admin/users/labels' do
    let(:params) { { key: 'document', value: 'pending' } }
    let(:do_request) { get '/api/v2/admin/users/labels', headers: auth_header, params: params }

    context 'admin user' do
      let(:test_user) { create(:user, role: 'admin') }

      let(:document_pending_count)  { 3 }
      let(:document_rejected_count) { 2 }
      let(:public_labels_count)     { 2 }

      before(:example) do
        document_pending_count.times do |i|
          create(:label, key: 'document', value: 'pending', scope: 'private')
        end

        document_rejected_count.times do |i|
          create(:label, key: 'document', value: 'rejected', scope: 'private')
        end
      end

      it 'renders error when key is missing' do
        get '/api/v2/admin/users/labels', headers: auth_header, params: {
          value: 'pending'
        }
        expect(response.status).to eq 422
        expect(response.body).to eq "{\"errors\":[\"admin.user.missing_key\"]}"
      end

      it 'renders error when value is missing' do
        get '/api/v2/admin/users/labels', headers: auth_header, params: {
          key: 'document'
        }
        expect(response.status).to eq 422
        expect(response.body).to eq "{\"errors\":[\"admin.user.missing_value\"]}"
      end

      it 'returns users' do
        get '/api/v2/admin/users/labels', headers: auth_header, params: {
          key: 'document',
          value: 'pending'
        }

        expect(json_body.count).to eq document_pending_count
      end

      context 'pagination test' do
        it 'returns 1st page as default, limit 2 users per page' do
          get '/api/v2/admin/users/labels', headers: auth_header, params: {
            key: 'document',
            value: 'pending',
            limit: 2
          }

          expect(json_body.count).to eq 2

          expect(json_body.first.keys).to match_array %i[email username uid role level otp state referral_uid data]
          expect(User.first.email).to eq json_body.first[:email]
          expect(User.second.email).to eq json_body.second[:email]

          expect(response.headers.fetch('Total')).to eq document_pending_count.to_s
          expect(response.headers.fetch('Page')).to eq '1'
          expect(response.headers.fetch('Per-Page')).to eq '2'
        end

        it 'returns 2nd page, limit 2 users per page' do
          get '/api/v2/admin/users/labels', headers: auth_header, params: {
            key: 'document',
            value: 'pending',
            limit: 2,
            page: 2
          }

          expect(User.third.email).to eq json_body.first[:email]

          expect(json_body.first.keys).to match_array %i[email username uid role level otp state referral_uid data]
          expect(response.headers.fetch('Total')).to eq document_pending_count.to_s
          expect(response.headers.fetch('Page')).to eq '2'
          expect(response.headers.fetch('Per-Page')).to eq '2'
        end
      end
    end
  end

  describe 'POST /api/v2/admin/users/update' do
    let!(:user)     { create(:user, otp: true) }
    let(:new_state) { 'banned' }
    let(:request)   { '/api/v2/admin/users/update' }
    let!(:superadmin) { create(:user, role: 'superadmin') }

    context 'admin user' do
      let(:test_user) { create(:user, role: 'admin') }

      it 'changes state' do
        post request, headers: auth_header, params: { uid: user.uid, state: new_state }

        expect(response.status).to eq 200
        expect(user.reload.state). to eq new_state
      end

      it 'changes state when superadmin user updates superadmin' do
        test_user.update!(role: 'superadmin')
        post request, headers: auth_header, params: { uid: superadmin.uid, state: 'banned' }

        expect(response.status).to eq 200
        expect(superadmin.reload.state). to eq 'banned'
      end

      it 'disables otp' do
        post request, headers: auth_header, params: { uid: user.uid, otp: false }

        expect(response.status).to eq 200
        expect(user.reload.otp).to eq false
      end

      it 'renders error when non-superadmin user updates superadmin' do
        post request, headers: auth_header, params: { uid: superadmin.uid, state: 'banned' }

        result = JSON.parse(response.body)
        expect(response.code).to eq '422'
        expect(result['errors']).to eq(['admin.user.superadmin_change'])
      end

      it 'renders error when state does not change' do
        post request, headers: auth_header, params: { uid: user.uid, state: user.state }

        expect(response.status).to eq 422
        expect(response.body).to eq "{\"errors\":[\"admin.user.state_no_change\"]}"
      end
    end
  end

  describe 'GET /api/v2/admin/users/documents/pending' do
    let(:do_request) { get '/api/v2/admin/users/documents/pending', headers: auth_header}

    context 'admin user' do
      let(:test_user) { create(:user, role: 'admin') }

      let(:private_document_pending_count)  { 3 }
      let(:private_document_replaced_count)  { 3 }
      let(:public_document_pending_count)  { 2 }

      context 'private pending documents' do
        before(:example) do
          private_document_pending_count.times do |i|
            create(:label, key: 'document', value: 'pending', scope: 'private')
          end
          public_document_pending_count.times do |i|
            create(:label, key: 'document', value: 'pending', scope: 'public')
          end
        end

        it 'returns users with profile and documents if params extended' do
          get '/api/v2/admin/users/documents/pending', headers: auth_header, params: { extended: true }

          expect(json_body.first.keys).to include(:profiles)
          expect(json_body.first.keys).to include(:documents)
          expect(json_body.count).to eq private_document_pending_count
        end

        it 'doesnt returns users with profile and documents if extended false' do
          get '/api/v2/admin/users/documents/pending', headers: auth_header, params: { extended: false }

          expect(json_body.first.keys).not_to include(:profile)
          expect(json_body.first.keys).not_to include(:documents)
          expect(json_body.count).to eq private_document_pending_count
        end

        it 'doesnt returns users with profile and documents if extended not provided' do
          get '/api/v2/admin/users/documents/pending', headers: auth_header

          expect(json_body.first.keys).not_to include(:profile)
          expect(json_body.first.keys).not_to include(:documents)
          expect(json_body.count).to eq private_document_pending_count
        end

        it 'returns users' do
          get '/api/v2/admin/users/documents/pending', headers: auth_header

          expect(json_body.first.keys).to_not include(:profile)
          expect(json_body.count).to eq private_document_pending_count
        end

        it 'returns users users with extended info' do
          get '/api/v2/admin/users/documents/pending', headers: auth_header, params: {extended: true}

          expect(json_body.first.keys).to include(:profiles)
          expect(json_body.count).to eq private_document_pending_count
        end
      end

      context 'private pending and replaced documents' do
        before(:example) do
          private_document_pending_count.times do |i|
            create(:label, key: 'document', value: 'pending', scope: 'private')
          end

          private_document_replaced_count.times do |i|
            create(:label, key: 'document', value: 'replaced', scope: 'private')
          end

          public_document_pending_count.times do |i|
            create(:label, key: 'document', value: 'pending', scope: 'public')
          end
        end

        it 'returns users with profile and documents with value pending and replaces' do
          get '/api/v2/admin/users/documents/pending', headers: auth_header, params: { extended: true }

          expect(json_body.first.keys).to include(:profiles)
          expect(json_body.first.keys).to include(:documents)
          expect(json_body.count).to eq private_document_pending_count + private_document_replaced_count
        end
      end

      context 'filtering' do
        before(:example) do
          private_document_pending_count.times do |i|
            create(:label, key: 'document', value: 'pending', scope: 'private')
          end
          public_document_pending_count.times do |i|
            create(:label, key: 'document', value: 'pending', scope: 'public')
          end
        end

        let(:params) { {} }
        let(:do_search_request) { get '/api/v2/admin/users/documents/pending', headers: auth_header, params: params }

        it 'returns filtered list of users when only one filter param given created_at and from' do
          params[:range] = 'created'
          User.first.update(created_at: 1.day.ago)
          params[:from] = 8.hours.ago.to_i
          do_search_request

          expect(response.status).to eq 200
          expect(json_body.count).to eq (private_document_pending_count - 1)
        end

        it 'returns filtered list of users when only one filter param given updated_at' do
          params[:range] = 'updated'
          User.first.update(updated_at: 1.day.ago)
          params[:from] = 8.hours.ago.to_i
          do_search_request

          expect(response.status).to eq 200
          expect(json_body.count).to eq (private_document_pending_count - 1)
        end

        it 'returns filtered list of users when only one filter param given (user attribute) level' do
          User.first.update(level: 2)
          params[:level] = 2
          do_search_request

          expect(json_body.count).to eq User.joins(:labels).where(labels: { key: 'document', value: 'pending', scope: 'private' }).where(level: 2).count
        end

        it 'returns filtered list of users when only one filter param given (user attribute) state' do
          params[:state] = 'active'
          do_search_request
          expect(response.status).to eq 200
          expect(json_body.count).to eq User.joins(:labels).where(labels: { key: 'document', value: 'pending', scope: 'private' }).where(state: 'active').count
        end

        it 'returns filtered list of users when several params given (user attribute) : state and level' do
          User.first.update(level: 2)
          params[:level] = 2
          params[:state] = 'active'
          do_search_request
          expect(response.status).to eq 200
          expect(json_body.count).to eq User.joins(:labels).where(labels: { key: 'document', value: 'pending', scope: 'private' }).where(level: 2, state: 'active').count
        end

        let(:profile) do
          create :profile, first_name: 'peatio',
                           last_name: 'barong',
                           country: 'us'
          Label.create(key: 'document', value: 'pending', scope: 'private', user_id: Profile.last.user_id)
        end

        it 'returns filtered list of users when only one filter param given (profile attribute) first_name' do
          profile
          params[:first_name] = 'peatio'
          do_search_request

          expect(response.status).to eq 200
        end

        it 'returns filtered list of users when several params given (profile attribute) : first_name and country' do
          profile
          params[:first_name] = 'peatio'
          params[:last_name] = 'barong'
          params[:country] = 'us'
          do_search_request

          expect(response.status).to eq 200
        end
      end

      context 'sorting test' do
        let!(:first_user) { create(:user) }
        let!(:second_user) { create(:user) }
        let!(:test_user) { create(:user, role: 'admin') }

        before(:example) do
          create(:label, key: 'document', value: 'pending', scope: 'private', user_id: second_user.id, created_at: 10.minutes.ago)
          create(:label, key: 'document', value: 'pending', scope: 'private', user_id: first_user.id, created_at: 5.minutes.ago)
        end

        it 'returns users sorted by time of label creation' do
          get '/api/v2/admin/users/documents/pending', headers: auth_header
          expect(json_body.last[:email]).to eq first_user.email
        end
      end

      context 'pagination test' do
        before(:example) do
          private_document_pending_count.times do |i|
            create(:label, key: 'document', value: 'pending', scope: 'private')
          end
          public_document_pending_count.times do |i|
            create(:label, key: 'document', value: 'pending', scope: 'public')
          end
        end

        it 'returns 1st page as default, limit 2 users per page' do
          get '/api/v2/admin/users/documents/pending', headers: auth_header, params: {
              limit: 2
          }

          expect(json_body.count).to eq 2
          expect(response.headers.fetch('Total')).to eq private_document_pending_count.to_s
          expect(response.headers.fetch('Page')).to eq '1'
          expect(response.headers.fetch('Per-Page')).to eq '2'
        end

        it 'returns 2nd page, limit 2 users per page' do
          get '/api/v2/admin/users/documents/pending', headers: auth_header, params: {
              limit: 2,
              page: 2
          }

          expect(response.headers.fetch('Total')).to eq private_document_pending_count.to_s
          expect(response.headers.fetch('Page')).to eq '2'
          expect(response.headers.fetch('Per-Page')).to eq '2'
        end
      end
    end
  end

  context 'comments' do
    describe 'POST /api/v2/admin/users/comments' do
      let(:url) { '/api/v2/admin/users/comments' }
      let(:params) { {} }
      let(:do_request) { post url, headers: auth_header, params: params }


      context 'successfull request' do
        let(:params) do
          {
            uid: experimental_user.uid,
            title: 'some useful title',
            data: 'some useless data.',
          }
        end
        let(:do_request) { post url, headers: auth_header, params: params }

        it 'creates new comment' do
          expect { do_request }.to change { Comment.count }.by 1
          expect(response.status).to eq 201
        end

        it 'saves author_uid' do
          do_request

          expect(json_body.keys).to match_array %i[email username uid role level otp state data profiles labels phones documents data_storages comments referral_uid created_at updated_at]
          expect(Comment.last.author_uid).to eq test_user.uid
          expect(json_body[:comments][0][:author_uid]).to eq test_user.uid
          expect(json_body[:profiles][0][:first_name]).to eq experimental_user.profiles[0].first_name
          expect(json_body[:profiles][0][:last_name]).to eq experimental_user.profiles[0].last_name
          expect(json_body[:profiles][0][:address]).to eq experimental_user.profiles[0].address
          expect(json_body[:profiles][0][:dob]).to eq experimental_user.profiles[0].dob.to_s
          expect(json_body[:documents][0][:doc_number]).to eq experimental_user.documents[0].doc_number
          expect(json_body[:phones][0][:number]).to eq experimental_user.phones[0].number
          expect(response.status).to eq 201
        end
      end

      context 'errored request' do
        let(:params) do
          {
            uid: experimental_user.uid,
            title: Faker::Lorem.characters(number: 65),
            data: 'some useless data.',
          }
        end

        it 'returns error because of length of comment' do
          expect { do_request }.to change { Comment.count }.by 0
          expect(json_body[:errors]).to eq ['admin.comments.title_too_long']
          expect(response.status).to eq 422
        end
      end
    end

    describe 'PUT /api/v2/admin/users/comments' do
      let(:url) { '/api/v2/admin/users/comments' }
      let!(:seeded) { Comment.create(author_uid: test_user.uid, user_id: experimental_user.id, title: 'preseeded record', data: 'prev') }
      let(:params) do
        {
          id: seeded.id,
          uid: experimental_user.uid,
          data: 'next.',
        }
      end
      let(:do_request) { put url, headers: auth_header, params: params }

      it 'does not create new comment' do
        expect { do_request }.not_to change { Comment.count }
        expect(response.status).to eq 200
      end

      it 'comment does not exist' do
        put url, headers: auth_header, params: { id: seeded.id+1, uid: experimental_user.uid, title: 'vv', data: 'ww' }
        expect(response.status).to eq 404
      end

      it 'changes data' do
        do_request
        expect(seeded.reload.data).to eq 'next.'
        expect(seeded.reload.title).to eq 'preseeded record'
        expect(response.status).to eq 200
      end
    end

    describe 'DELETE /api/v2/admin/users/comments' do
      let(:url) { '/api/v2/admin/users/comments' }
      let!(:seeded) { Comment.create(author_uid: test_user.uid, user_id: experimental_user.id, title: 'preseeded record', data: 'prev') }
      let(:params) { { id: seeded.id } }
      let(:do_request) { delete url, headers: auth_header, params: params }

      it 'does not create new comment' do
        expect { do_request }.to change { Comment.count }.by -1
        expect(response.status).to eq 200
      end

      it 'comment does not exist' do
        put url, headers: auth_header, params: { id: seeded.id+1, uid: experimental_user.uid, title: 'vv', data: 'ww' }
        expect(response.status).to eq 404
      end
    end
  end
end
