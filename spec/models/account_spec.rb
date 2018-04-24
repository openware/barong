# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Account, type: :model do
  ## Test of validations
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
  it { should have_many(:documents).dependent(:destroy) }

  ## Test of relationships
  it { should have_one(:profile).dependent(:destroy) }

  let(:uploaded_file) { fixture_file_upload('/files/documents_test.jpg', 'image/jpg') }

  context 'Account with 2 or more documents' do
    it do
      account = Account.create!(email: 'test@mail.com', password: '123123')
      expect(Account.count).to eq 1
      document1 = account.documents.create!(upload: uploaded_file,
                                            doc_type: 'Passport',
                                            doc_number: 'MyString',
                                            doc_expire: '01-01-2020')
      document2 = account.documents.create!(upload: uploaded_file,
                                            doc_type: 'Passport',
                                            doc_number: 'MyString',
                                            doc_expire: '01-02-2020')
      expect(account.reload.documents).to eq([document1, document2])
    end

    after(:all) { Account.destroy_all }
  end

  describe '#set_level' do
    let!(:account) { create(:account, level: 0) }
    let(:account_level) do
      Label.find_by(account_id: account.id, key: 'account_level')&.value
    end

    before { account.level_set(level) }

    context 'when mail' do
      let(:level) { :mail }
      it { expect(account.reload.level).to eq 1 }
      it { expect(account_level).to eq 'email_verified' }
    end

    context 'when phone' do
      let(:level) { :phone }
      it { expect(account.reload.level).to eq 2 }
      it { expect(account_level).to eq 'phone_verified' }
    end

    context 'when identity' do
      let(:level) { :identity }
      it { expect(account.reload.level).to eq 3 }
      it { expect(account_level).to eq 'documents_checked' }
    end

    context 'when address' do
      let(:level) { :address }
      it { expect(account.reload.level).to eq 4 }
    end
  end
end
