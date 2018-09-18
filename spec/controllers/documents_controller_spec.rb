# frozen_string_literal: true

RSpec.describe DocumentsController, type: :controller do
  let!(:current_account) { create(:account, level: 2) }
  let(:document) { build(:document, account: current_account) }

  before { login_as current_account }

  let(:valid_attributes) do
    {
      doc_type: document.doc_type,
      doc_number: document.doc_number,
      doc_expire: document.doc_expire,
      upload: fixture_file_upload('/files/documents_test.jpg', 'image/jpg')
    }
  end

  let(:invalid_attributes) do
    {
      doc_type: 'type'
    }
  end

  let(:valid_session) { {} }

  describe 'GET #new' do
    context 'when account has low level' do
      let!(:current_account) { create(:account) }

      it 'redirects to new_phone_path' do
        set_level(current_account, 1)
        get :new, params: {}
        expect(response).to redirect_to(new_phone_path)
      end
    end

    it 'returns a success response' do
      get :new, params: {}
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'when account has low level' do
      let!(:current_account) { create(:account, level: 1) }

      it 'redirects to new_phone_path' do
        post :create, params: { document: valid_attributes }
        expect(response).to redirect_to(new_phone_path)
      end
    end

    context 'with valid params' do
      it 'creates a new Document' do
        expect do
          post :create, params: { document: valid_attributes }
        end.to change(Document, :count).by(1)
      end

      it 'redirects to index page' do
        post :create, params: { document: valid_attributes }
        expect(flash[:notice]).to eq('Document was successfully uploaded.')
        expect(response).to redirect_to(index_path)
      end
    end

    context 'with invalid params' do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { document: invalid_attributes }
        expect(flash[:alert]).to eq('Some fields are empty or invalid')
        expect(response).to be_successful
      end
    end
  end
end
