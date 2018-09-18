# frozen_string_literal: true

RSpec.describe ProfilesController, type: :controller do
  let!(:current_account) { create(:account) }
  let!(:level) { 2 }

  before do
    set_level(current_account, level)
    login_as current_account
  end

  let(:profile) { build :profile }

  let(:valid_attributes) do
    {
      first_name: profile.first_name,
      last_name: profile.last_name,
      dob: profile.dob,
      address: profile.address,
      postcode: profile.postcode,
      city: profile.city,
      country: profile.country
    }
  end

  let(:invalid_attributes) do
    {
      first_name: Faker::Name.first_name
    }
  end

  describe 'GET #new' do
    context 'when profile already exists' do
      let!(:profile) { create :profile, account: current_account }

      it 'redirects to new_document_path' do
        get :new, params: {}
        expect(response).to redirect_to(new_document_path)
      end
    end

    context 'when account has low level' do
      let!(:current_account) { create(:account) }
      let!(:level) { 1 }

      it 'redirects to new_phone_path' do
        get :new, params: {}
        expect(response).to redirect_to(new_phone_path)
      end
    end

    context 'when account has no profile' do
      it 'returns a success response' do
        get :new, params: {}
        expect(response).to be_successful
      end
    end
  end

  describe 'POST #create' do
    context 'when profile already exists' do
      let!(:profile) { create :profile, account: current_account }

      it 'redirects to new_document_path' do
        post :create, params: { profile: valid_attributes }
        expect(response).to redirect_to(new_document_path)
      end
    end

    context 'when account has low level' do
      let!(:current_account) { create(:account) }
      let(:level) { 1 }

      it 'redirects to new_phone_path' do
        post :create, params: { profile: valid_attributes }
        expect(response).to redirect_to(new_phone_path)
      end
    end

    context 'with valid params' do
      it 'creates a new Profile' do
        expect do
          post :create, params: { profile: valid_attributes }
        end.to change(Profile, :count).by(1)
      end

      it 'redirects to the new document path' do
        post :create, params: { profile: valid_attributes }
        expect(response).to redirect_to(new_document_path)
      end
    end

    context 'with invalid params' do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { profile: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end
end
