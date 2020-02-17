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
  it { should validate_length_of(:first_name).is_at_most(255) }
  it { should validate_length_of(:city).is_at_most(255) }
  it { should validate_length_of(:last_name).is_at_most(255) }

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

  describe 'creating partial priofile' do
    let!(:create_member_permission) do
      create :permission,
              role: 'member'
    end
    let!(:user) { create(:user) }

    subject { Profile.create(params.merge(user_id: user.id)) }

    context 'empty params' do
      let!(:params) { {} }

      it { expect(subject).to be_valid }

      it { expect(subject.first_name.nil?).to be_truthy }

      it { expect(subject.last_name.nil?).to be_truthy }

      it { expect(subject.dob.nil?).to be_truthy }

      it { expect(subject.address.nil?).to be_truthy }

      it { expect(subject.postcode.nil?).to be_truthy }

      it { expect(subject.city.nil?).to be_truthy }

      it { expect(subject.country.nil?).to be_truthy }

      it { expect(subject.metadata.nil?).to be_truthy }

      it { expect(subject.state).to eq('drafted') }

      it { expect(subject.user.labels.find_by(key: 'profile').value).to eq('drafted') }

      context 'add empty params' do

        let!(:params) {
          {
            last_name: Faker::Name.last_name,
            first_name: Faker::Name.first_name,
            dob: Faker::Date.birthday,
            country: Faker::Address.country_code_long,
            city: Faker::Address.city,
            address: Faker::Address.street_address,
            postcode: Faker::Address.zip_code
          }
        }

        before do
          subject.update(params)
        end

        it { expect(subject).to be_valid }

        it { expect(subject.first_name.present?).to be_truthy }

        it { expect(subject.last_name.present?).to be_truthy }

        it { expect(subject.dob.present?).to be_truthy }

        it { expect(subject.address.present?).to be_truthy }

        it { expect(subject.postcode.present?).to be_truthy }

        it { expect(subject.city.present?).to be_truthy }

        it { expect(subject.country.present?).to be_truthy }

        it { expect(subject.metadata.nil?).to be_truthy }

        it { expect(subject.state).to eq('drafted') }

        it { expect(subject.user.labels.find_by(key: 'profile').value).to eq('drafted') }
      end
    end

    context 'all profile params' do

      let!(:params) {
        {
          last_name: Faker::Name.last_name,
          first_name: Faker::Name.first_name,
          dob: Faker::Date.birthday,
          country: Faker::Address.country_code_long,
          city: Faker::Address.city,
          address: Faker::Address.street_address,
          postcode: Faker::Address.zip_code
        }
      }

      it { expect(subject).to be_valid }

      it { expect(subject.first_name.present?).to be_truthy }

      it { expect(subject.last_name.present?).to be_truthy }

      it { expect(subject.dob.present?).to be_truthy }

      it { expect(subject.address.present?).to be_truthy }

      it { expect(subject.postcode.present?).to be_truthy }

      it { expect(subject.city.present?).to be_truthy }

      it { expect(subject.country.present?).to be_truthy }

      it { expect(subject.metadata.present?).to be_falsey }

      it { expect(subject.state).to eq('drafted') }

      it { expect(subject.user.labels.find_by(key: 'profile').value).to eq('drafted') }
    end
  end

  context 'event api behaviour' do
    let!(:permission) { create(:permission, role: 'member') }
    let!(:user) { create(:user, state: 'pending', role: 'member') }
    let!(:profile) { create(:profile, user_id: user.id, first_name: old_name, state: 'drafted') }
    let!(:old_name) { Faker::Name.first_name }
    let!(:new_name) { Faker::Name.first_name }

    let(:profile_update) { profile.update(first_name: new_name ) }

    before do
      allow(EventAPI).to receive(:notify)
    end

    it 'receives event with label create' do
      profile_update

      expect(EventAPI).to have_received(:notify).with('model.profile.updated',
                                                      hash_including(
                                                      changes: { first_name: old_name },
                                                      record: hash_including(first_name: new_name)
                                                     ))
    end
  end
end
