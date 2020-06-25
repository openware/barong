# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Restriction, type: :model do
  context 'create' do
    it { should_not allow_value('planet').for(:scope) }

    it 'valid address with ip scope' do
      expect(Restriction.new(scope: 'ip', value: '127.0.0.1', category: 'denylist').valid?).to be_truthy
    end

    it 'invalid address with ip scope' do
      expect(Restriction.new(scope: 'ip', value: 'abc.0.0.1', category: 'denylist').valid?).to be_falsey
    end

    it 'ip subnet with ip scope' do
      expect(Restriction.new(scope: 'ip', value: '127.0.0.1/24', category: 'denylist').valid?).to be_falsey
    end

    it 'valid subnet with ip_subnet scope' do
      expect(Restriction.new(scope: 'ip_subnet', value: '127.0.0.1/24', category: 'denylist').valid?).to be_truthy
    end

    it 'invalid subnet with ip_subnet scope' do
      expect(Restriction.new(scope: 'ip_subnet', value: '127.0.0.1/one', category: 'denylist').valid?).to be_falsey
    end

    it 'ip address with ip_subnet scope' do
      expect(Restriction.new(scope: 'ip_subnet', value: '127.0.0.1', category: 'denylist').valid?).to be_falsey
    end
  end
end
