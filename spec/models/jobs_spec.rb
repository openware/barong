# frozen_string_literal: true

RSpec.describe Job, type: :model do
  context 'creation' do
    context 'with valid parameters' do
      subject(:job) { create(:job) }
      it { expect(job).to_not be_nil }
    end
  end

  context 'validation' do
    context 'valid values' do
      it { should allow_value('maintenance').for(:type) }
      it { should allow_value('pending').for(:state) }
      it { should allow_value('active').for(:state) }
      it { should allow_value('disabled').for(:state) }
    end

    context 'invalid values' do
      it "invalid type" do
        expect(Job.new(type: '').valid?).to be_falsey
      end
    end

    
    # it { should_not allow_value('planet').for(:scope) }

    # it 'valid address with ip scope' do
    #   expect(Restriction.new(scope: 'ip', value: '127.0.0.1', category: 'blacklist').valid?).to be_truthy
    # end

    # it 'invalid address with ip scope' do
    #   expect(Restriction.new(scope: 'ip', value: 'abc.0.0.1', category: 'blacklist').valid?).to be_falsey
    # end

    # it 'ip subnet with ip scope' do
    #   expect(Restriction.new(scope: 'ip', value: '127.0.0.1/24', category: 'blacklist').valid?).to be_falsey
    # end

    # it 'valid subnet with ip_subnet scope' do
    #   expect(Restriction.new(scope: 'ip_subnet', value: '127.0.0.1/24', category: 'blacklist').valid?).to be_truthy
    # end

    # it 'invalid subnet with ip_subnet scope' do
    #   expect(Restriction.new(scope: 'ip_subnet', value: '127.0.0.1/one', category: 'blacklist').valid?).to be_falsey
    # end

    # it 'ip address with ip_subnet scope' do
    #   expect(Restriction.new(scope: 'ip_subnet', value: '127.0.0.1', category: 'blacklist').valid?).to be_falsey
    # end
  end

end
