# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Document, type: :model do
  ## Test of relationships
  it { should belong_to(:account) }

  context 'Document creation' do
    let!(:current_account) { create(:account) }
    let(:create_document) { create :document, account: current_account }

    context 'when it is first document' do
      it 'adds new document label' do
        expect(current_account.labels).to be_empty
        create_document
        expect(current_account.labels).to_not be_empty
      end

      it 'new document label is document: pending' do
        create_document
        expect(current_account.labels.first.key).to eq 'document'
        expect(current_account.labels.first.value).to eq 'pending'
      end
    end

    context 'when user has label document: rejected' do
      let!(:document_label) do
        create :label,
               scope: 'private',
               key: 'document',
               value: 'rejected',
               account: current_account
      end

      it 'does not add new label' do
        create_document
        expect(current_account.labels.count).to eq 1
      end

      it 'changes label value to pending' do
        create_document
        expect(current_account.labels.first.value).to eq 'pending'
      end
    end

    context 'when user has label document: verified' do
      let!(:document_label) do
        create :label,
               scope: 'private',
               key: 'document',
               value: 'verified',
               account: current_account
      end

      it 'does not add new label' do
        create_document
        expect(current_account.labels.count).to eq 1
      end

      it 'remains value verified' do
        create_document
        expect(current_account.labels.first.value).to eq 'verified'
      end
    end
  end
end
