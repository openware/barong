# frozen_string_literal: true

RSpec.describe Label, type: :model do
  it { should belong_to(:account) }

  describe 'update account level if label defined as level', order: :defined do
    let!(:email_verified_level)    { create :level, id: 1, key: 'email',    value: 'verified' }
    let!(:phone_verified_level)    { create :level, id: 2, key: 'phone',    value: 'verified' }
    let!(:identity_verified_level) { create :level, id: 3, key: 'identity', value: 'verified' }
    let!(:document_verified_level) { create :level, id: 4, key: 'document', value: 'verified' }

    context 'when account has no labels' do
      let!(:account) { create(:account) }
      it { expect(account.reload.level).to eq 0 }

      it 'does not change level if valid label has public scope' do
        expect do
          create_label_with_level(account, email_verified_level, scope: 'public')
        end.to_not change { account.reload.level }
      end

      it 'when checks labels-levels mappings' do
        expect do
          create_label_with_level(account, email_verified_level)
        end.to change { account.reload.level }.from(0).to(1)

        expect do
          create_label_with_level(account, phone_verified_level)
        end.to change { account.reload.level }.from(1).to(2)

        expect do
          create_label_with_level(account, identity_verified_level)
        end.to change { account.reload.level }.from(2).to(3)

        expect do
          create_label_with_level(account, document_verified_level)
        end.to change { account.reload.level }.from(3).to(4)
      end
    end

    context 'when account has verified email and phone' do
      let!(:account) { create(:account) }

      before do
        create_label_with_level(account, email_verified_level)
        create_label_with_level(account, phone_verified_level)
      end

      it 'changes to level 2 when identity verified label applied' do
        expect(account.reload.level).to eq(2)
      end

      it 'changes to level 3 when identity verified label applied' do
        expect do
          create_label_with_level(account, identity_verified_level)
        end.to change { account.reload.level }.to(3)
      end

      it 'downgrades level to 1 when phone state changes to rejected' do
        Label.find_by(account: account, key: phone_verified_level.key).update(value: 'rejected')
        expect(account.reload.level).to eq 1
      end

      it 'does not change level if account has document verified label' do
        expect do
          create_label_with_level(account, document_verified_level)
        end.to_not change { account.reload.level }
      end
    end

    context 'when account has all label required for level 4' do
      let!(:account) { create(:account) }
      before do
        create_label_with_level(account, email_verified_level)
        create_label_with_level(account, phone_verified_level)
        create_label_with_level(account, identity_verified_level)
        create_label_with_level(account, document_verified_level)
      end

      it { expect(account.reload.level).to eq 4 }

      it 'downgrades level to 0 when email verified label changes' do
        Label.find_by(account: account, key: email_verified_level.key).update(value: 'rejected')
        expect(account.reload.level).to eq 0
      end

      it 'downgrades level to 0 when email verified label changes' do
        Label.find_by(account: account, key: email_verified_level.key).destroy
        expect(account.reload.level).to eq 0
      end
    end
  end
end
