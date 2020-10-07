# frozen_string_literal: true

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
    let(:create_document) { create :document, user: current_user, doc_type: 'Passport', doc_category: 'front_side' }
    let(:create_document_second) { create :document, user: current_user, doc_type: 'Passport', doc_category: 'selfie' }
    let(:create_without_label) { create :document, user: current_user, update_labels: false }
    let(:document_label) { current_user.labels.first }

    context 'when it is first document' do
      it 'adds new document label' do
        create_document
        expect { create_document_second }.to change { current_user.reload.labels.count }.from(0).to(1)
      end

      it 'new document label is document: pending' do
        create_document
        create_document_second
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
               user: current_user
      end

      it 'does not add new label' do
        create_document
        expect { create_document_second }.to_not change { Label.count }
      end

      it 'changes label value to pending' do
        create_document
        create_document_second
        expect(current_user.labels.first.value).to eq 'pending'
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

  context 'submasked fields' do
    let!(:current_user) { create(:user) }
    let(:document) { create :document, user: current_user, doc_type: 'Passport', doc_number: 'M0993353' }
    let(:document_without_doc_number) { create :document, user: current_user, doc_type: 'Passport', doc_number: nil }

    context 'number' do
      it { expect(document.sub_masked_doc_number).to eq 'M0****53' }
      it { expect(document_without_doc_number.sub_masked_doc_number).to eq nil }

      it 'should mask first 2 letters and last 2 digits' do
        document.update(doc_type: 'Driver license', doc_number: 'BO231283013DSAS23')
        expect(document.sub_masked_doc_number).to eq 'BO*************23'
      end
    end
  end
end
