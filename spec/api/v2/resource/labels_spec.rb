# frozen_string_literal: true

require 'spec_helper'

describe 'Labels API.' do
  include_context 'bearer authentication'
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  let!(:create_admin_permission) do
    create :permission,
           role: 'admin'
  end
  let(:post_params) do
    {
      key: ::Faker::Internet.slug(glue: '-'),
      value: ::Faker::Internet.slug(glue: '-')
    }
  end

  context 'Happy paths for the current user.' do
    let(:test_user) { create(:user, role: "admin") }
    let!(:label) { create :label, user: test_user }
    let!(:label2) { create :label, user: test_user }
    let!(:label3) { create :label, user: test_user }

    it 'Return lables for current user' do
      get '/api/v2/resource/labels', headers: auth_header

      expect(response.status).to eq(200)
      expect(json_body.size).to eq(3)
      expect(json_body.last[:key]).to eq(label3.key)
    end

    it 'Return a label by key' do
      get "/api/v2/resource/labels/#{label.key}", headers: auth_header
      expect(response.status).to eq(200)
      expect(json_body[:key]).to eq(label.key)
    end

    it 'Create a label' do
      post '/api/v2/resource/labels', params: post_params, headers: auth_header
      expect(response.status).to eq(201)
      persisted = Label.find_by(key: json_body[:key])
      expect(persisted.key).to eq(post_params[:key])
      expect(persisted.value).to eq(post_params[:value])
      expect(persisted.scope).to eq('public')
      expect(persisted.user_id).to eq(test_user.id)
    end

    it 'Update a label' do
      patch "/api/v2/resource/labels/#{label.key}", params: post_params, headers: auth_header
      expect(response.status).to eq(200)
      persisted = Label.find_by(key: label.key)
      expect(persisted.value).to eq(post_params[:value])
      expect(persisted.scope).to eq('public')
    end

    it 'Delete a label' do
      delete "/api/v2/resource/labels/#{label.key}", headers: auth_header
      expect(response.status).to eq(204)
      expect(Label.find_by(key: label.key)).to be_nil
    end
  end

  context 'Errors.' do
    let(:test_user) { create(:user, role: "admin") }
    let!(:label) { create :label, user: test_user }

    it 'Respond with errors on create if existing key is used for current user' do
      post '/api/v2/resource/labels', params: post_params.merge(key: label.key), headers: auth_header
      expect(response.status).to eq(422)
      expect(response.body).to be_include('key.taken')
    end

    it 'Respond with error if attempted to update a private label' do
      label.update(scope: 'private')
      patch "/api/v2/resource/labels/#{label.key}", params: post_params, headers: auth_header
      expect(response.status).to eq(400)
    end

    it 'Respond with error if key not found' do
      get '/api/v2/resource/labels/blah', headers: auth_header
      expect(response.status).to eq(404)
    end
  end
end
