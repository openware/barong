# frozen_string_literal: true

RSpec.describe Label, type: :model do
  it { should belong_to(:account) }

  describe 'update account level if label defined as level', order: :defined do
    let(:email_verified_level)    { create :level, id: 1, key: 'email',    value: 'verified' }
    let(:phone_verified_level)    { create :level, id: 2, key: 'phone',    value: 'verified' }
    let(:identity_verified_level) { create :level, id: 3, key: 'identity', value: 'verified' }
    let(:document_verified_level) { create :level, id: 4, key: 'document', value: 'verified' }

    context 'when account has verified phone' do
      subject!(:account) { create(:account) }

      it 'changes to level 3 when identity verified label applied' do
        Label.create(account: account, key: email_verified_level.key, value: email_verified_level.value)
        Label.create(account: account, key: phone_verified_level.key, value: phone_verified_level.value)
        Label.create(account: account, key: identity_verified_level.key, value: identity_verified_level.value)
        expect(account.reload.level).to eq 3
      end

      it 'downgrades level to 1 when phone state changes to rejected' do
        Label.create(account: account, key: email_verified_level.key, value: email_verified_level.value)
        Label.create(account: account, key: phone_verified_level.key, value: phone_verified_level.value)
        expect(account.reload.level).to eq 2
        Label.find_by(account: account, key: phone_verified_level.key).update(value: 'rejected')
        expect(account.reload.level).to eq 1
      end
    end
  end
end
