# frozen_string_literal: true

RSpec.describe Phone, type: :model do
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end

  context 'submasked fields' do
    let!(:phone) { create(:phone) }

    context 'number' do
      it 'should mask country code and last 4 digits' do
        phone.update(number: '79225551234')
        expect(phone.sub_masked_number).to eq '7******1234'
      end

      it 'should mask country code and last 4 digits' do
        phone.update(number: '+201112341923')
        expect(phone.sub_masked_number).to eq '20******1923'
      end

      it 'should mask country code and last 4 digits' do
        phone.update(number: '+380971232322')
        expect(phone.sub_masked_number).to eq '380*****2322'
      end

      it 'should return empty phone number' do
        phone.update(number: '')
        expect(phone.sub_masked_number).to eq ''
      end

      context 'default country code' do
        it 'should mask country code' do
          phone.update_attribute(:number, '1112222')
          expect(phone.sub_masked_number).to eq '11*2222'
        end
      end
    end
  end
end
