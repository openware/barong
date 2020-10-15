# frozen_string_literal: true

RSpec.describe APIKey, type: :model do
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end

  let!(:create_service_account_permission) do
    create :permission,
           role: 'service_account'
  end

  describe 'Validations' do
    subject(:api_key) { build(:api_key, :with_user) }

    it { should validate_presence_of(:secret).with_message(/can't be blank/) }
    it { should validate_uniqueness_of(:kid).with_message(/has already been taken/) }

    context 'key holder state' do
      context 'valid response' do
        context 'user with active state' do
          let!(:user) { create(:user, state: 'active') }

          it 'creates api key' do
            subject.key_holder_account = user
            expect(subject.save).to eq true
            expect(subject.errors.full_messages).to eq []
          end
        end

        context 'service account with active state' do
          let!(:user) { create(:user, state: 'active') }
          let!(:service_account) { create(:service_account, owner_id: user.id) }

          it 'creates api key' do
            subject.key_holder_account = user
            expect(subject.save).to eq true
            expect(subject.errors.full_messages).to eq []
          end
        end
      end

      context 'invalid response' do
        subject { build(:api_key) }

        context 'user with non active state' do
          let!(:user) { create(:user, state: 'pending') }

          it 'render error message' do
            subject.key_holder_account = user
            expect(subject.save).to eq false
            expect(subject.errors.full_messages).to include(/non active state for key holder account/)
          end
        end

        context 'service account with non active state' do
          let!(:user) { create(:user, state: 'pending') }
          let!(:service_account) { create(:service_account, owner_id: user.id) }

          it 'render error message' do
            subject.key_holder_account = service_account
            expect(subject.save).to eq false
            expect(subject.errors.full_messages).to include(/non active state for key holder account/)
          end
        end
      end
    end

    context 'api key state on update' do
      context 'valid response' do
        context 'user with active state' do
          let!(:user) { create(:user, state: 'active') }
          let!(:api_key) { create(:api_key, key_holder_account: user, state: 'disabled') }

          it 'updates api key state' do
            api_key.state = 'active'
            expect(api_key.save).to eq true
            expect(api_key.errors.full_messages).to eq []
          end
        end

        context 'service account with non active state' do
          let!(:user) { create(:user, state: 'active') }
          let!(:service_account) { create(:service_account, owner_id: user.id) }
          let!(:api_key) { create(:api_key, key_holder_account: service_account, state: 'disabled') }

          it 'render error message' do
            api_key.state = 'active'
            expect(api_key.save).to eq true
            expect(api_key.errors.full_messages).to eq []
          end
        end
      end

      context 'invalid response' do
        context 'user with non active state' do
          let!(:user) { create(:user, state: 'active') }
          let!(:api_key) { create(:api_key, key_holder_account: user) }

          it 'render error message' do
            user.update(state: 'banned')
            api_key.state = 'active'
            expect(api_key.save).to eq false
            expect(api_key.errors.full_messages).to include(/cant activate api key with disabled key holder account/)
          end
        end

        context 'service account with non active state' do
          let!(:user) { create(:user, state: 'active') }
          let!(:service_account) { create(:service_account, owner_id: user.id) }
          let!(:api_key) { create(:api_key, key_holder_account: service_account) }

          it 'render error message' do
            service_account.update(state: 'disabled')
            api_key.state = 'active'
            expect(api_key.save).to eq false
            expect(api_key.errors.full_messages).to include(/cant activate api key with disabled key holder account/)
          end
        end
      end
    end
  end
end
