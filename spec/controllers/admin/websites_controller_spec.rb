# frozen_string_literal: true

require 'spec_helper'

describe Admin::WebsitesController, type: :controller do
  let!(:current_account) { create(:account, role: 'admin') }
  before { login_as current_account }

  let(:website) { build :website }
  let(:valid_attributes) do
    website.attributes
           .slice('domain', 'title', 'logo', 'stylesheet',
                  'header', 'footer', 'redirect_url', 'state')
  end

  describe 'GET #index' do
    let!(:website) { create(:website) }

    it 'returns a success response' do
      get :index, params: {}
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    let!(:website) { create(:website) }

    it 'returns a success response' do
      get :show, params: { id: website.to_param }
      expect(response).to be_successful
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new, params: {}
      expect(response).to be_successful
    end
  end

  describe 'GET #edit' do
    let!(:website) { create(:website) }

    it 'returns a success response' do
      get :edit, params: { id: website.to_param }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Website' do
        expect do
          post :create, params: { website: valid_attributes }
        end.to change(Website, :count).by(1)
      end

      it 'redirects to the created website' do
        post :create, params: { website: valid_attributes }
        expect(response).to redirect_to(admin_websites_url)
      end
    end
  end

  describe 'PUT #update' do
    let!(:website) { create(:website) }

    context 'with valid params' do
      let(:new_attributes) do
        {
          domain: Faker::Internet.domain_name
        }
      end

      it 'updates the requested website' do
        expect do
          put :update, params: { id: website.to_param, website: new_attributes }
        end.to change { website.reload.domain }.to new_attributes[:domain]
      end

      it 'redirects to the website' do
        put :update, params: { id: website.to_param, website: valid_attributes }
        expect(response).to redirect_to(admin_websites_url)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:website) { create(:website) }

    it 'destroys the requested website' do
      expect do
        delete :destroy, params: { id: website.to_param }
      end.to change(Website, :count).by(-1)
    end

    it 'redirects to the websites list' do
      delete :destroy, params: { id: website.to_param }
      expect(response).to redirect_to(admin_websites_url)
    end
  end
end
