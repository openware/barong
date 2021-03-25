# frozen_string_literal: true

describe KycService do
  let!(:create_member_permission) do
    create :permission,
           role: 'member',
           verb: 'all'
    create :permission,
           role: 'member',
           verb: 'all',
           path: 'tasty_endpoint'
  end
  let!(:user) { create :user }

  context 'document_label_update' do

    context 'update label' do
      let!(:label) { create(:label, user: user, key: 'document', scope: 'private', value: 'rejected') }

      it 'should update label' do
        expect(user.labels.count).to eq 1
        expect(user.labels.first.key).to eq 'document'
        KycService.document_label_update(user)
        expect(user.labels.count).to eq 1
        expect(user.labels.first.key).to eq 'document'
        expect(user.labels.first.scope).to eq 'private'
        expect(user.labels.first.value).to eq 'pending'
      end
    end

    context 'create label' do
      it 'should create label' do
        expect(user.labels.count).to eq 0
        KycService.document_label_update(user)
        expect(user.labels.count).to eq 1
        expect(user.labels.first.key).to eq 'document'
        expect(user.labels.first.scope).to eq 'private'
        expect(user.labels.first.value).to eq 'pending'
      end
    end
  end
end
