# frozen_string_literal: true

# == Schema Information
#
# Table name: documents
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           unsigned, not null
#  upload     :string(255)
#  doc_type   :string(255)
#  doc_number :string(255)
#  doc_expire :date
#  metadata   :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


require 'rails_helper'

RSpec.describe Document, type: :model do
  ## Test of relationships
  let!(:create_admin_permission) do
    create :permission,
           role: 'admin'
  end
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  it { should belong_to(:user) }

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
    let!(:current_user) { create(:user) }
    let(:create_document) { create :document, user: current_user }
    let(:create_without_label) { create :document, user: current_user, update_labels: false }
    let(:document_label) { current_user.labels.first }

    context 'when it is first document' do
      it 'adds new document label' do
        expect { create_document }.to change { current_user.reload.labels.count }.from(0).to(1)
      end

      it 'new document label is document: pending' do
        create_document
        expect(document_label.key).to eq 'document'
        expect(document_label.value).to eq 'pending'
      end

      it 'does not add label if flag given' do
        create_without_label
        expect(document_label).to be_nil
        expect(document_label).to be_nil
      end
    end

    context 'when user has label document: rejected' do
      let!(:document_label) do
        create :label,
               scope: 'private',
               key: 'document',
               value: 'rejected',
               user: current_user
      end

      it 'does not add new label' do
        expect { create_document }.to_not change { Label.count }
      end

      it 'changes label value to pending' do
        create_document
        expect(current_user.labels.first.value).to eq 'pending'
      end

      it 'does not change label value if flag given' do
        create_without_label
        expect(current_user.labels.first.value).to eq 'rejected'
      end
    end

    context 'when user has label document: verified' do
      let!(:document_label) do
        create :label,
               scope: 'private',
               key: 'document',
               value: 'verified',
               user: current_user
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
