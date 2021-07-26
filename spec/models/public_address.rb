# frozen_string_literal: true

RSpec.describe PublicAddress, type: :model do
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end

  context 'PublicAddress model basic syntax' do
    ## Test of UID creation
    it 'creates default uid with prefix PA' do
      public_address = create(:public_address)
      expect(public_address.uid).to start_with(PublicAddress::UID_PREFIX)
    end

    it 'should return payload' do
      public_address = create(:public_address)
      payload = public_address.as_payload
      expect(payload['uid']).to eq(public_address.uid)
      expect(payload['level']).to eq(public_address.level)
      expect(payload['state']).to eq(public_address.state)
      expect(payload['role']).to eq(public_address.role)
    end
  end
end
