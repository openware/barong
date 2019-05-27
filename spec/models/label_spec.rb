# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Label, type: :model do
  let!(:create_admin_permission) do
    create :permission,
           role: 'admin'
  end
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  it { should belong_to(:user) }

  describe 'update user level if label defined as level', order: :defined do
    let!(:email_verified_level)    { Level.find(1) }
    let!(:phone_verified_level)    { Level.find(2) }
    let!(:identity_verified_level) { Level.find(3) }
    let!(:document_verified_level) { Level.find(4) }

    context 'when user has no labels' do
      let!(:user) { create(:user) }
      it { expect(user.reload.level).to eq 0 }

      it 'does not change level if valid label has public scope' do
        expect do
          create_label_with_level(user, email_verified_level, scope: 'public')
        end.to_not change { user.reload.level }
      end

      it 'when checks labels-levels mappings' do
        expect do
          create_label_with_level(user, email_verified_level)
        end.to change { user.reload.level }.from(0).to(1)

        expect do
          create_label_with_level(user, phone_verified_level)
        end.to change { user.reload.level }.from(1).to(2)

        expect do
          create_label_with_level(user, identity_verified_level)
        end.to change { user.reload.level }.from(2).to(3)

        expect do
          create_label_with_level(user, document_verified_level)
        end.to change { user.reload.level }.from(3).to(4)
      end
    end

    context 'when user has verified email and phone' do
      let!(:user) { create(:user) }

      before do
        create_label_with_level(user, email_verified_level)
        create_label_with_level(user, phone_verified_level)
      end

      it 'changes to level 2 when identity verified label applied' do
        expect(user.reload.level).to eq(2)
      end

      it 'changes to level 3 when identity verified label applied' do
        expect do
          create_label_with_level(user, identity_verified_level)
        end.to change { user.reload.level }.to(3)
      end

      it 'downgrades level to 1 when phone state changes to rejected' do
        Label.find_by(user: user, key: phone_verified_level.key).update(value: 'rejected')
        user.update_level
        expect(user.reload.level).to eq 1
      end
      
      it 'does not change level if user has document verified label' do
        expect do
          create_label_with_level(user, document_verified_level)
        end.to_not change { user.reload.level }
      end
    end

    context 'when user has all label required for level 4' do
      let!(:user) { create(:user) }
      before do
        create_label_with_level(user, email_verified_level)
        create_label_with_level(user, phone_verified_level)
        create_label_with_level(user, identity_verified_level)
        create_label_with_level(user, document_verified_level)
      end

      it { expect(user.reload.level).to eq 4 }

      it 'downgrades level to 0 when email verified label changes' do
        Label.find_by(user: user, key: email_verified_level.key).update(value: 'rejected')
        user.update_level
        expect(user.reload.level).to eq 0
      end

      it 'downgrades level to 0 when email verified label changes' do
        Label.find_by(user: user, key: email_verified_level.key).destroy
        user.update_level
        expect(user.reload.level).to eq 0
      end
    end

    context 'document label changes' do
      let!(:user) { create(:user) }
      let(:last_mailer_delivery) { ActionMailer::Base.deliveries.last }
      let!(:document_label) do
        create(
          :label,
          user: user,
          key: 'document',
          value: 'pending',
          scope: 'private'
        )
      end
    end

    context 'when label scope is changed from private to public and reverse' do
      let!(:user) { create(:user) }

      before do
        create_label_with_level(user, email_verified_level)
        create_label_with_level(user, phone_verified_level)
        create_label_with_level(user, identity_verified_level)
        create_label_with_level(user, document_verified_level)
      end

      it 'updates level' do
        expect do
          user.labels.last.update(scope: :public)
        end.to change { user.reload.level }.from(4).to(3)

        expect do
          user.labels.last.update(scope: :private)
        end.to change { user.reload.level }.from(3).to(4)
      end
    end

    context '2 labels with same keys' do
      let!(:user) { create(:user) }
      let!(:label_public) do
        create :label,
                user: user,
                key: email_verified_level.key,
                value: email_verified_level.value,
                scope: 'public'
      end

      let!(:label_private) do
        create :label,
                user: user,
                key: email_verified_level.key,
                value: email_verified_level.value,
                scope: 'private'
      end

      context 'can be created with different scopes' do
        it 'user has both labels' do
          expect(user.labels).to include(label_private, label_public)
        end

        it 'user has level 1' do
          expect(user.level).to eq 1
        end

        context 'when private label changes' do
          it 'user level downgrades when value changed' do
            expect { label_private.update(value: 'rejected') }.to change { user.reload.level }.to 0
          end

          it 'user level downgrades when key changed' do
            expect { label_private.update(key: 'email0') }.to change { user.reload.level }.to 0
          end
        end

        context 'when public label changes' do
          it 'user level does not change' do
            expect { label_public.update(value: 'rejected') }.to_not change { user.reload.level }
          end
        end
      end
    end

    context 'when user has all required labels for level 4 in wrong scope' do
      let!(:user) { create(:user) }
      let!(:label_email_public) do
        create :label,
                user: user,
                key: email_verified_level.key,
                value: email_verified_level.value,
                scope: 'public'
      end
      let!(:label_phone_public) do
        create :label,
                user: user,
                key: phone_verified_level.key,
                value: phone_verified_level.value,
                scope: 'public'
      end
      let!(:label_identity_public) do
        create :label,
                user: user,
                key: identity_verified_level.key,
                value: identity_verified_level.value,
                scope: 'public'
      end
      let!(:label_document_public) do
        create :label,
                user: user,
                key: document_verified_level.key,
                value: document_verified_level.value,
                scope: 'public'
      end

      it { expect(user.reload.level).to eq 0 }
    end
  end

  context 'downcase fields' do
    let(:user) { create(:user) }
    let(:label) { build(:label, user: user, key: 'PhoNe', value: 'VeRifiEd') }

    it 'downcases key and value before save' do
      label.save
      expect(label.reload.key).to eq 'phone'
      expect(label.reload.value).to eq 'verified'
    end
  end
end
