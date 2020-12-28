# frozen_string_literal: true

RSpec.describe Restriction, type: :model do
  context 'create' do
    it { should_not allow_value('planet').for(:scope) }

    it 'valid address with ip scope' do
      expect(Restriction.new(scope: 'ip', value: '127.0.0.1', category: 'blacklist').valid?).to be_truthy
    end

    it 'invalid address with ip scope' do
      expect(Restriction.new(scope: 'ip', value: 'abc.0.0.1', category: 'blacklist').valid?).to be_falsey
    end

    it 'ip subnet with ip scope' do
      expect(Restriction.new(scope: 'ip', value: '127.0.0.1/24', category: 'blacklist').valid?).to be_falsey
    end

    it 'valid subnet with ip_subnet scope' do
      expect(Restriction.new(scope: 'ip_subnet', value: '127.0.0.1/24', category: 'blacklist').valid?).to be_truthy
    end

    it 'invalid subnet with ip_subnet scope' do
      expect(Restriction.new(scope: 'ip_subnet', value: '127.0.0.1/one', category: 'blacklist').valid?).to be_falsey
    end

    it 'ip address with ip_subnet scope' do
      expect(Restriction.new(scope: 'ip_subnet', value: '127.0.0.1', category: 'blacklist').valid?).to be_falsey
    end
  end

  context 'session destroy' do
    let!(:permission) { create :permission, role: 'member'}
    let(:user) { create(:user) }

    before do
      allow(Rails.cache).to receive(:delete_matched).and_return(nil)
    end

    context 'blocklogin category' do
      context 'after create' do
        it do
          expect(Rails.cache).to receive(:delete_matched)
          Restriction.create!(scope: 'ip', value: '127.0.0.1', category: 'blocklogin', state: "enabled")
        end

        it do
          expect(Rails.cache).to_not receive(:delete_matched)
          Restriction.create!(scope: 'ip', value: '127.0.0.2', category: 'blocklogin', state: "disabled")
        end
      end

      context 'after update' do
        let!(:enabled_restriction) {create(:restriction, scope: 'ip', value: '127.0.0.3', category: 'blocklogin', state: "enabled")}
        let!(:disabled_restriction) {create( :restriction, scope: 'ip', value: '127.0.0.4', category: 'blocklogin', state: "disabled")}

        it do
          expect(Rails.cache).to receive(:delete_matched)
          disabled_restriction.update(state: "enabled")
        end

        it do
          expect(Rails.cache).to_not receive(:delete_matched)
          enabled_restriction.update(state: "enabled")
        end

        it do
          expect(Rails.cache).to_not receive(:delete_matched)
          disabled_restriction.update(state: "disabled")
        end

        it do
          expect(Rails.cache).to_not receive(:delete_matched)
          enabled_restriction.update(state: "disabled")
        end
      end
    end

    context 'another category' do
      it 'it should not destroy sessions' do
        expect(Rails.cache).to_not receive(:delete_matched)
        Restriction.create!(scope: 'ip', value: '127.0.0.1', category: 'blacklist', state: "enabled")
      end
    end
  end
end
