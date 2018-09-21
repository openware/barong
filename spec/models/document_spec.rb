# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Document, type: :model do
  ## Test of relationships
  it { should belong_to(:account) }

  describe 'validation' do
    let!(:document) { build :document, doc_expire: doc_expire }
    subject do
      document.valid?
      document.errors.messages
    end
    let(:doc_expire) { Date.current.to_s }
    it { is_expected.to be_blank }

    context 'when doc_expire is expired' do
      let(:doc_expire) { 1.day.ago.to_s }

      it { is_expected.to eq(doc_expire: ['is invalid']) }
    end
  end

  context 'Document creation' do
    let!(:current_account) { create(:account) }
    let(:create_document) { create :document, account: current_account }
    let(:document_label) { current_account.labels.first }

    context 'when it is first document' do
      it 'adds new document label' do
        expect { create_document }.to change { current_account.reload.labels.count }.from(0).to(1)
      end

      it 'new document label is document: pending' do
        create_document
        expect(document_label.key).to eq 'document'
        expect(document_label.value).to eq 'pending'
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
        expect { create_document }.to_not change { Label.count }
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
        expect { create_document }.to_not change { Label.count }
      end

      it 'remains value verified' do
        expect { create_document }.to_not change { document_label }
      end
    end
  end
end
