# frozen_string_literal: true

# == Schema Information
#
# Table name: profiles
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)
#  first_name :string(255)
#  last_name  :string(255)
#  dob        :date
#  address    :string(255)
#  postcode   :string(255)
#  city       :string(255)
#  country    :string(255)
#  metadata   :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Profile, type: :model do
    ## Test of relationships
    it { should belong_to(:user) }
    it { should validate_presence_of(:first_name) }
    it { should validate_length_of(:first_name).is_at_most(255) }
    it { should validate_length_of(:city).is_at_most(255) }
    it { should validate_length_of(:last_name).is_at_most(255) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:dob) }
    it { should validate_presence_of(:address) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:postcode) }
  
    describe 'squish_spaces' do
      let!(:create_member_permission) do
        create :permission,
               role: 'member'
      end
      let!(:profile) do
        create :profile, first_name: '  First  Name ',
                         last_name: '  Last   Name  ',
                         city: '  New  York ',
                         postcode: '  AB   135-144  '
      end
  
      it 'squishes spaces' do
        profile.reload
        expect(profile.first_name).to eq 'First Name'
        expect(profile.last_name).to eq 'Last Name'
        expect(profile.city).to eq 'New York'
        expect(profile.postcode).to eq 'AB 135-144'
      end
    end
end
