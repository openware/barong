# frozen_string_literal: true

require 'spec_helper'
describe API::V2::Admin::Users do
  include_context 'bearer authentication'
  let!(:create_admin_permission) do
    create :permission,
           role: 'admin'
  end
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end

  let(:experimental_user) { create(:user, state: "pending") }

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
        user.attributes.slice('email', 'role', 'level', 'otp', 'state', 'uid').symbolize_keys
      end

      it 'returns list of users' do
        do_request

        expect(User.count).to eq json_body.count
        expect(validate_fields(User.first)).to eq json_body.first.except(:referral_uid)
        expect(validate_fields(User.second)).to eq json_body.second.except(:referral_uid)
        expect(validate_fields(User.third)).to eq json_body.third.except(:referral_uid)
        expect(validate_fields(User.fourth)).to eq json_body.fourth.except(:referral_uid)

        expect(json_body.first.keys).to_not include(:profile)

        expect(response.headers.fetch('Total')).to eq User.all.count.to_s
        expect(response.headers.fetch('Page')).to eq '1'
        expect(response.headers.fetch('Per-Page')).to eq '100'
      end

      it 'returns filtered list of users when only one filter param given created_at and from' do
        params[:range] = 'created'
        User.first.update(created_at: 1.day.ago)
        params[:from] = User.last.created_at.to_i
        do_search_request

        expect(response.status).to eq 200
        expect(json_body.count).to eq (User.all.count - 1)
      end

      it 'returns filtered list of users when only one filter param given (user attribute) level' do
        params[:level] = 2
        do_search_request
        expect(response.status).to eq 200
        expect(json_body.count).to eq User.where(level: 2).count
      end

      it 'returns filtered list of users when only one filter param given (user attribute) state' do
        params[:state] = 'active'
        do_search_request
        expect(response.status).to eq 200
        expect(json_body.count).to eq User.where(state: 'active').count
      end

      it 'returns filtered list of users when several params given (user attribute) : state and level' do
        params[:level] = 2
        params[:state] = 'active'
        do_search_request
        expect(response.status).to eq 200
        expect(json_body.count).to eq User.where(level: 2, state: 'active').count
      end

      let!(:profile) do
        create :profile, first_name: 'peatio',
                         last_name: 'barong',
                         country: 'us'
      end

      it 'returns filtered list of users when only one filter param given (profile attribute) first_name' do
        params[:first_name] = 'peatio'
        do_search_request
        expect(response.status).to eq 200
      end

      it 'returns filtered list of users when several params given (profile attribute) : first_name and country' do
        params[:first_name] = 'peatio'
        params[:last_name] = 'barong'
        params[:country] = 'barong'
        do_search_request
        expect(response.status).to eq 200
      end

      let(:extended_params) { { extended: true } }
      let(:do_extended_info_request) { get '/api/v2/admin/users', headers: auth_header, params: extended_params }

      it 'returns list of users with full info' do
        do_extended_info_request
        expect(User.count).to eq json_body.count

        expect(json_body.first.keys).to include(:profile)

        expect(response.headers.fetch('Total')).to eq User.all.count.to_s
        expect(response.headers.fetch('Page')).to eq '1'
        expect(response.headers.fetch('Per-Page')).to eq '100'
      end

      it 'returns list of users (ASC ordered) in search' do
        params[:email] = 'testa@gmail.com'
        do_search_request

        expect(json_body.count).to eq 1
        expect(json_body[0][:email]).to eq 'testa@gmail.com'
      end

      it 'returns all users (ASC ordered) in search req if field is not in the list' do
        params.clear
        params[:field] = 'bazz'
        do_search_request

        expect(json_body.count).to eq User.all.count

        expect_status.to eq(200)
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
        end
      end
    end
  end

  describe 'PUT /api/v2/admin/users' do
    let(:do_request) { put '/api/v2/admin/users', headers: auth_header }

    context 'admin user' do
      let(:test_user) { create(:user, role: "admin") }
      let(:user_with_api_keys) { create(:user, state: "active", otp: true) }
      let!(:api_key1) { create(:api_key, user: user_with_api_keys) }
      let!(:api_key2) { create(:api_key, user: user_with_api_keys) }
      it 'renders error if uid is misssing' do
        put '/api/v2/admin/users', headers: auth_header, params: {
          state: 'active'
        }
        expect(response.status).to eq 422
        expect(response.body).to eq "{\"errors\":[\"admin.user.missing_uid\",\"admin.user.empty_uid\"]}"
      end

      it 'renders error if state is misssing' do
        put '/api/v2/admin/users', headers: auth_header, params: {
          uid: experimental_user.uid
        }
        expect(response.status).to eq 422
        expect(response.body).to eq "{\"errors\":[\"admin.user.one_of_state_otp\"]}"
      end

      it 'renders error if otp is misssing' do
        put '/api/v2/admin/users', headers: auth_header, params: {
          uid: experimental_user.uid
        }
        expect(response.status).to eq 422
        expect(response.body).to eq "{\"errors\":[\"admin.user.one_of_state_otp\"]}"
      end

      it 'renders error if role is misssing' do
        put '/api/v2/admin/users', headers: auth_header, params: {
          uid: experimental_user.uid
        }
        expect(response.status).to eq 422
        expect(response.body).to eq "{\"errors\":[\"admin.user.one_of_state_otp\"]}"
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
        put '/api/v2/admin/users', headers: auth_header, params: {
          uid: experimental_user.uid,
          otp: 'false'
        }
        expect(response.status).to eq 200
        expect(experimental_user.reload.otp).to eq false
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
  end

  describe 'Get /api/v2/admin/users/:uid' do
    let(:do_request) { get '/api/v2/admin/users/' + experimental_user.uid, headers: auth_header }

    context 'admin user' do
      let(:test_user) { create(:user, role: "admin") }

      it 'renders error if uid is invalid' do
        get '/api/v2/admin/users/asdasdsad', headers: auth_header
        expect(response.status).to eq 404
        expect(response.body).to eq "{\"errors\":[\"admin.user.doesnt_exist\"]}"
      end

      it 'returns user info' do
        do_request
        expect(response.status).to eq 200
        expect(json_body[:uid]).to eq experimental_user.uid
        expect(json_body[:role]).to eq experimental_user.role
        expect(json_body[:email]).to eq experimental_user.email
        expect(json_body[:level]).to eq experimental_user.level
        expect(json_body[:otp]).to eq experimental_user.otp
        expect(json_body[:state]).to eq experimental_user.state
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

      it 'renders error when key is missing' do
        post '/api/v2/admin/users/labels', headers: auth_header, params: {
          uid: experimental_user.uid,
          value: 'vedified'
        }
        expect(response.status).to eq 422
        expect(response.body).to eq "{\"errors\":[\"admin.user.missing_key\",\"admin.user.empty_key\"]}"
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

      it 'adds label with default public scope' do
        post '/api/v2/admin/users/labels', headers: auth_header, params: {
          uid: experimental_user.uid,
          key: 'email',
          value: 'verified'
        }
        updated_user = experimental_user.reload
        added_label = updated_user.labels.last
        expect(response.status).to eq 200
        expect(added_label.key).to eq 'email'
        expect(added_label.value).to eq 'verified'
        expect(added_label.scope).to eq 'public'
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

  describe 'POST /api/v2/admin/labels' do
    let(:do_request) { delete '/api/v2/admin/users/labels', headers: auth_header }

    context 'admin user' do
      let(:test_user) { create(:user, role: 'admin') }
      let(:add_label) {
        post '/api/v2/admin/users/labels', headers: auth_header, params: {
          uid: experimental_user.uid,
          key: 'email',
          value: 'verified'
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
        expect(experimental_user.labels).to eq []
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

    context 'admin user' do
      let(:test_user) { create(:user, role: 'admin') }

      it 'changes state' do
        post request, headers: auth_header, params: { uid: user.uid, state: new_state }

        expect(response.status).to eq 200
        expect(user.reload.state). to eq new_state
      end

      it 'disables otp' do
        post request, headers: auth_header, params: { uid: user.uid, otp: false }

        expect(response.status).to eq 200
        expect(user.reload.otp).to eq false
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
      let(:public_document_pending_count)  { 2 }

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

        expect(json_body.first.keys).to include(:profile)
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

        expect(json_body.first.keys).to include(:profile)
        expect(json_body.count).to eq private_document_pending_count
      end

      context 'filtering' do
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
        let(:test_user) { create(:user, role: 'admin') }
        let(:first_user) { create(:user) }
        let(:second_user) { create(:user) }

        before(:example) do
          create(:label, key: 'document', value: 'pending', scope: 'private', user_id: second_user.id)
          create(:label, key: 'document', value: 'pending', scope: 'private', user_id: first_user.id)
        end

        it 'returns users sorted by time of label creation' do
          get '/api/v2/admin/users/documents/pending', headers: auth_header
          expect(json_body.last[:email]).to eq first_user.email
        end
      end

      context 'pagination test' do
        it 'returns 1st page as default, limit 2 users per page' do
          get '/api/v2/admin/users/documents/pending', headers: auth_header, params: {
              limit: 2
          }

          expect(json_body.count).to eq 2
          expect(User.first.email).to eq json_body.first[:email]
          expect(User.second.email).to eq json_body.second[:email]

          expect(response.headers.fetch('Total')).to eq private_document_pending_count.to_s
          expect(response.headers.fetch('Page')).to eq '1'
          expect(response.headers.fetch('Per-Page')).to eq '2'
        end

        it 'returns 2nd page, limit 2 users per page' do
          get '/api/v2/admin/users/documents/pending', headers: auth_header, params: {
              limit: 2,
              page: 2
          }

          expect(User.third.email).to eq json_body.first[:email]

          expect(response.headers.fetch('Total')).to eq private_document_pending_count.to_s
          expect(response.headers.fetch('Page')).to eq '2'
          expect(response.headers.fetch('Per-Page')).to eq '2'
        end
      end
    end
  end
end
