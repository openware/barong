# frozen_string_literal: true

require 'spec_helper'

describe API::V2::Admin::Users do
  include_context 'bearer authentication'

  let(:experimental_user) { create(:user, state: "pending") }

  describe 'GET /api/v2/admin/users' do
    let(:do_request) { get '/api/v2/admin/users', headers: auth_header }

    context 'non-admin user' do
      it 'access denied to non-admin user' do
        do_request
        expect(response.status).to eq 401
        expect(response.body).to eq "{\"errors\":[\"admin.access.denied\"]}"
      end
    end

    context 'admin user' do
      let(:test_user) { create(:user, email: 'testa@gmail.com', role: 'admin') }
      let(:second_user) { create(:user, email: 'testb@gmail.com') }
      let(:third_user) { create(:user, email: 'testd@gmail.com') }
      let(:fourth_user) { create(:user, email: 'testc@gmail.com') }

      let(:params) do {
        field: 'email',
        value: 'testa@gmail.com'
      }
      end
      let(:do_search_request) { get '/api/v2/admin/users/search', headers: auth_header, params: params }

      before(:example) {
        test_user
        second_user
        third_user
        fourth_user
      }

      def validate_fields(user)
        user.attributes.slice('email', 'role', 'level', 'otp', 'state', 'uid')
      end
      it 'returns list of users' do
        do_request
        users = JSON.parse(response.body)
        expect(User.count).to eq users.count
        expect(validate_fields(User.first)).to eq users.first
        expect(validate_fields(User.second)).to eq users.second
        expect(validate_fields(User.third)).to eq users.third
        expect(validate_fields(User.last)).to eq users.last

        expect(response.headers.fetch('Total')).to eq '4'
        expect(response.headers.fetch('Page')).to eq '1'
        expect(response.headers.fetch('Per-Page')).to eq '100'
      end

      it 'returns list of users (ASC ordered) in search' do
        do_search_request
        users = JSON.parse(response.body)

        expect(users.count).to eq 1
        expect(users[0]['email']).to eq 'testa@gmail.com'
      end

      it 'returns all users (ASC ordered) in search req if field is invalid' do
        params[:field] = 'bazz'
        do_search_request
        expect_body.to eq(errors: ['admin.user.non_user_field'])
        expect_status.to eq(422)
      end

      context 'pagination test' do
        it 'returns 1st page as default, limit 2 users per page' do
          get '/api/v2/admin/users', headers: auth_header, params: {
            limit: 2
          }
          users = JSON.parse(response.body)
          expect(validate_fields(User.first)).to eq users.first
          expect(validate_fields(User.second)).to eq users.second

          expect(response.headers.fetch('Total')).to eq '4'
          expect(response.headers.fetch('Page')).to eq '1'
          expect(response.headers.fetch('Per-Page')).to eq '2'
        end

        it 'returns 2nd page, limit 2 users per page' do
          get '/api/v2/admin/users', headers: auth_header, params: {
            limit: 2,
            page: 2
          }
          users = JSON.parse(response.body)
          expect(validate_fields(User.third)).to eq users.first
          expect(validate_fields(User.last)).to eq users.second

          expect(response.headers.fetch('Total')).to eq '4'
          expect(response.headers.fetch('Page')).to eq '2'
          expect(response.headers.fetch('Per-Page')).to eq '2'
        end
      end
    end
  end

  describe 'PUT /api/v2/admin/users' do
    let(:do_request) { put '/api/v2/admin/users', headers: auth_header }

    context 'non-admin user' do
      it 'access denied to non-admin user' do
        do_request
        expect(response.status).to eq 401
        expect(response.body).to eq "{\"errors\":[\"admin.access.denied\"]}"
      end
    end

    context 'admin user' do
      let(:test_user) { create(:user, role: "admin") }
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
        expect(response.body).to eq "{\"errors\":[\"admin.user.one_of_role_state_otp\"]}"
      end

      it 'renders error if otp is misssing' do
        put '/api/v2/admin/users', headers: auth_header, params: {
          uid: experimental_user.uid
        }
        expect(response.status).to eq 422
        expect(response.body).to eq "{\"errors\":[\"admin.user.one_of_role_state_otp\"]}"
      end

      it 'renders error if role is misssing' do
        put '/api/v2/admin/users', headers: auth_header, params: {
          uid: experimental_user.uid
        }
        expect(response.status).to eq 422
        expect(response.body).to eq "{\"errors\":[\"admin.user.one_of_role_state_otp\"]}"
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
        put '/api/v2/admin/users', headers: auth_header, params: {
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
    end
  end

  describe 'Get /api/v2/admin/users/:uid' do
    let(:do_request) { get '/api/v2/admin/users/' + experimental_user.uid, headers: auth_header }

    context 'non-admin user' do
      it 'access denied to non-admin user' do
        do_request
        expect(response.status).to eq 401
        expect(response.body).to eq "{\"errors\":[\"admin.access.denied\"]}"
      end
    end

    context 'admin user' do
      let(:test_user) { create(:user, role: "admin") }

      it 'renders error if uid is invalid' do
        get '/api/v2/admin/users/asdasdsad', headers: auth_header
        expect(response.status).to eq 404
        expect(response.body).to eq "{\"errors\":[\"admin.user.doesnt_exist\"]}"
      end

      it 'returns user info' do
        do_request
        result = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(result['uid']).to eq experimental_user.uid
        expect(result['role']).to eq experimental_user.role
        expect(result['email']).to eq experimental_user.email
        expect(result['level']).to eq experimental_user.level
        expect(result['otp']).to eq experimental_user.otp
        expect(result['state']).to eq experimental_user.state
      end
    end
  end

  describe 'POST /api/v2/admin/labels' do
    let(:do_request) { post '/api/v2/admin/users/labels', headers: auth_header }

    context 'non-admin user' do
      it 'access denied to non-admin user' do
        do_request
        expect(response.status).to eq 401
        expect(response.body).to eq "{\"errors\":[\"admin.access.denied\"]}"
      end
    end

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

    context 'non-admin user' do
      it 'access denied to non-admin user' do
        do_request
        expect(response.status).to eq 401
        expect(response.body).to eq "{\"errors\":[\"admin.access.denied\"]}"
      end
    end

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

  describe 'DELETE /api/v2/admin/users/cleanup' do
    let(:do_request) { delete '/api/v2/admin/users/cleanup', headers: auth_header }

    context 'non-admin user' do
      it 'access denied to non-admin user' do
        do_request
        expect(response.status).to eq 401
        expect(response.body).to eq "{\"errors\":[\"admin.access.denied\"]}"
      end
    end

    context 'admin user' do
      let(:test_user) { create(:user, role: 'admin') }

      it 'renders error when updated_at_limit is missing' do
        delete '/api/v2/admin/users/cleanup', headers: auth_header, params: {}
        expect(response.status).to eq 422
      end

      it 'renders error when updated_at_limit is invalid' do
        delete '/api/v2/admin/users/cleanup', headers: auth_header, params: {
          updated_at_limit: 'date',
        }
        expect(response.status).to eq 422
      end

      it 'deletes pending users with updated_at < updated_at_limit' do
        3.times { create(:user, state: 'pending') }
        User.last.update(state: 'active')

        delete '/api/v2/admin/users/cleanup', headers: auth_header, params: {
          updated_at_limit: '2019-03-11T18:02:35+02:00'
        }

        expect(User.all.count).to eq 1
      end

      it 'deletes unvalidated phones with updated_at < updated_at_limit' do
        3.times { create(:phone, validated_at: nil) }
        Phone.last.update(validated_at: DateTime.now)

        delete '/api/v2/admin/users/cleanup', headers: auth_header, params: {
          updated_at_limit: '2019-03-11T18:02:35+02:00'
        }

        expect(Phone.all.count).to eq 1
      end
    end
  end

end
