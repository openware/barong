# frozen_string_literal: true

RSpec.describe Organization, type: :model do
  context 'Organization model basic syntax' do
    ## Test of CODE creation
    it 'creates default oid with prefix ID' do
      default_organization = create(:organization, name: 'Company Test',
                                                   group: 'vip-0')
      expect(default_organization.oid).to start_with(Barong::App.config.oid_prefix)
    end

    describe '#name' do
      it 'create organization with nil name' do
        expect { create(:organization, name: nil) }.to raise_error ActiveRecord::RecordInvalid
      end

      it 'create organization with unique name' do
        create(:organization, name: 'Company A')
        expect { create(:organization, name: 'Company A') }.to raise_error ActiveRecord::RecordInvalid
      end
    end

    describe '#group' do
      it 'create organization with nil group' do
        expect { create(:organization, group: nil) }.to raise_error ActiveRecord::RecordInvalid
      end
    end
  end
end
