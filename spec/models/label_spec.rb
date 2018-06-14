# frozen_string_literal: true

RSpec.describe Label, type: :model do
  it { should belong_to(:account) }

  describe 'update account level if label defined as level', order: :defined do
    let!(:email_verified_level)    { Level.find(1) }
    let!(:phone_verified_level)    { Level.find(2) }
    let!(:identity_verified_level) { Level.find(3) }
    let!(:document_verified_level) { Level.find(4) }

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

    context 'document label changes' do
      let!(:account) { create(:account) }
      let(:last_mailer_delivery) { ActionMailer::Base.deliveries.last }
      let!(:document_label) do
        create(
          :label,
          account: account,
          key: 'document',
          value: 'pending',
          scope: 'private'
        )
      end

      context 'when label value is verified' do
        it 'sends notification email' do
          document_label.update(value: 'verified')
          expect(last_mailer_delivery.to).to eq [account.email]
          expect(last_mailer_delivery.subject).to eq 'Your identity was approved'
        end
      end

      context 'when label value is rejected' do
        it 'sends notification email' do
          document_label.update(value: 'rejected')
          expect(last_mailer_delivery.to).to eq [account.email]
          expect(last_mailer_delivery.subject).to eq 'Your identity was rejected'
        end
      end
    end

    context 'when label scope is changed from private to public and reverse' do
      let!(:account) { create(:account) }

      before do
        create_label_with_level(account, email_verified_level)
        create_label_with_level(account, phone_verified_level)
        create_label_with_level(account, identity_verified_level)
        create_label_with_level(account, document_verified_level)
      end

      it 'updates level' do
        expect do
          account.labels.last.update(scope: :public)
        end.to change { account.reload.level }.from(4).to(3)

        expect do
          account.labels.last.update(scope: :private)
        end.to change { account.reload.level }.from(3).to(4)
      end
    end

    context '2 labels with same keys' do
      let!(:account) { create(:account) }
      let!(:label_public) do
        create :label,
               account: account,
               key: email_verified_level.key,
               value: email_verified_level.value,
               scope: 'public'
      end

      let!(:label_private) do
        create :label,
               account: account,
               key: email_verified_level.key,
               value: email_verified_level.value,
               scope: 'private'
      end

      context 'can be created with different scopes' do
        it 'account has both labels' do
          expect(account.labels).to eq [label_public, label_private]
        end

        it 'account has level 1' do
          expect(account.level).to eq 1
        end

        context 'when private label changes' do
          it 'account level downgrades when value changed' do
            expect { label_private.update(value: 'rejected') }.to change { account.reload.level }.to 0
          end

          it 'account level downgrades when key changed' do
            expect { label_private.update(key: 'email0') }.to change { account.reload.level }.to 0
          end
        end

        context 'when public label changes' do
          it 'account level does not change' do
            expect { label_public.update(value: 'rejected') }.to_not change { account.reload.level }
          end
        end
      end
    end

    context 'when account has all required labels for level 4 in wrong scope' do
      let!(:account) { create(:account) }
      let!(:label_email_public) do
        create :label,
               account: account,
               key: email_verified_level.key,
               value: email_verified_level.value,
               scope: 'public'
      end
      let!(:label_phone_public) do
        create :label,
               account: account,
               key: phone_verified_level.key,
               value: phone_verified_level.value,
               scope: 'public'
      end
      let!(:label_identity_public) do
        create :label,
               account: account,
               key: identity_verified_level.key,
               value: identity_verified_level.value,
               scope: 'public'
      end
      let!(:label_document_public) do
        create :label,
               account: account,
               key: document_verified_level.key,
               value: document_verified_level.value,
               scope: 'public'
      end

      it { expect(account.reload.level).to eq 0 }
    end
  end

  context 'downcase fields' do
    let(:label) { build(:label, key: 'PhoNe', value: 'VeRifiEd') }

    it 'downcases key and value before save' do
      label.save
      expect(label.reload.key).to eq 'phone'
      expect(label.reload.value).to eq 'verified'
    end
  end
end
