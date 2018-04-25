# frozen_string_literal: true

require 'spec_helper'

describe 'Labels API.' do
  include_context 'doorkeeper authentication'

  let!(:label) { create :label, account: current_account }

  let(:post_params) do
    {
      key: ::Faker::Internet.slug(nil, '-'),
      value: ::Faker::Internet.slug(nil, '-')
    }
  end

  context 'Happy paths for the current account.' do
    it 'Return lables for current account' do
      get '/api/v1/labels', headers: auth_header
      expect(response.status).to eq(200)
      expect(json_body.size).to eq(1)
      expect(json_body.first[:key]).to eq(label.key)
    end

    it 'Return a label by key' do
      get "/api/v1/labels/#{label.key}", headers: auth_header
      expect(response.status).to eq(200)
      expect(json_body[:key]).to eq(label.key)
    end

    it 'Create a label' do
      post '/api/v1/labels', params: post_params, headers: auth_header
      expect(response.status).to eq(201)
      persisted = Label.find_by(key: json_body[:key])
      expect(persisted.key).to eq(post_params[:key])
      expect(persisted.value).to eq(post_params[:value])
      expect(persisted.scope).to eq('public')
      expect(persisted.account_id).to eq(current_account.id)
    end

    it 'Update a label' do
      patch "/api/v1/labels/#{label.key}", params: post_params, headers: auth_header
      expect(response.status).to eq(200)
      persisted = Label.find_by(key: label.key)
      expect(persisted.value).to eq(post_params[:value])
      expect(persisted.scope).to eq('public')
    end

    it 'Delete a label' do
      delete "/api/v1/labels/#{label.key}", headers: auth_header
      expect(response.status).to eq(204)
      expect(Label.find_by(key: label.key)).to be_nil
    end
  end

  context 'Errors.' do
    it 'Respond with errors on create if existing key is used for current account' do
      post '/api/v1/labels', params: post_params.merge(key: label.key), headers: auth_header
      expect(response.status).to eq(422)
      expect(response.body).to be_include('Key has already been taken')
    end

    it 'Respond with error if attempted to update a private label' do
      label.update(scope: 'private')
      patch "/api/v1/labels/#{label.key}", params: post_params, headers: auth_header
      expect(response.status).to eq(400)
    end

    it 'Respond with error if key not found' do
      get '/api/v1/labels/blah', headers: auth_header
      expect(response.status).to eq(404)
    end
  end
end
