# frozen_string_literal: true

RSpec.describe Profile, type: :model do
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

    subject { Profile.create(params.merge(user: user)) }

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

  context 'profile_state!' do
    let!(:create_member_permission) do
      create :permission,
              role: 'member'
    end

    let!(:user) { create(:user) }
    let!(:verified_profile) { create(:profile, user_id: user.id, state: 'verified') }
    let!(:rejected_profile) { create(:profile, user_id: user.id, state: 'rejected') }
    let!(:drafted_profile) { create(:profile, user_id: user.id, state: 'drafted') }
    let!(:profile_params) {
      {
        user_id: user.id,
        last_name: Faker::Name.last_name,
        first_name: Faker::Name.first_name,
        dob: Faker::Date.birthday,
        country: Faker::Address.country_code_long,
        city: Faker::Address.city,
        address: Faker::Address.street_address,
        postcode: Faker::Address.zip_code
      }
    }

    it 'profile with state drafted' do
      profile = Profile.new(profile_params)
      profile.save
      profile.valid?

      expect(profile.errors[:state]).to eq(['already exists'])
    end

    it 'profile with state submitted' do
      profile = Profile.new(profile_params.merge(state: 'submitted'))
      profile.save
      profile.valid?

      expect(profile.errors[:state]).to eq(['already exists'])
    end

    it 'profile with state verified' do
      profile = Profile.new(profile_params.merge(state: 'verified'))
      profile.save
      expect(profile.valid?).to eq true
    end

    it 'profile with state rejected' do
      profile = Profile.new(profile_params.merge(state: 'rejected'))
      profile.save
      expect(profile.valid?).to eq true
    end
  end

  context 'create_or_update_profile_label' do
    let!(:create_member_permission) do
      create :permission,
              role: 'member'
    end

    let!(:user) { create(:user) }
    let!(:profile_params) {
      {
        user_id: user.id,
        last_name: Faker::Name.last_name,
        first_name: Faker::Name.first_name,
        dob: Faker::Date.birthday,
        country: Faker::Address.country_code_long,
        city: Faker::Address.city,
        address: Faker::Address.street_address,
        postcode: Faker::Address.zip_code
      }
    }

    it 'creating profile label' do
      expect(user.labels.count).to eq 0

      Profile.create(profile_params)
      expect(user.labels.count).to eq 1
      expect(user.labels.first.key).to eq 'profile'
      expect(user.labels.first.value).to eq 'drafted'
    end

    it 'updating profile label' do
      profile = Profile.create(profile_params.merge(state: 'submitted'))
      expect(user.labels.count).to eq 1
      expect(user.labels.first.key).to eq 'profile'
      expect(user.labels.first.value).to eq 'submitted'

      expect(user.labels.count).to eq 1

      profile.update(state: 'verified')
      expect(user.labels.count).to eq 1
      expect(user.labels.first.key).to eq 'profile'
      expect(user.labels.first.value).to eq 'verified'
    end

    context 'dob param' do
      let!(:profile) { create(:profile, user_id: user.id, state: 'verified') }

      it 'should be valid dob' do
        profile.update(dob: Time.now)
        expect(profile.valid?).to eq true
      end

      it 'should be invalid dob format' do
        profile.update(dob: '')
        expect(profile.valid?).to eq false
        expect(profile.errors[:dob]).to eq ["invalid date format"]
      end

      it 'should be invalid dob format' do
        profile.update(dob: Time.now + 3.days)
        expect(profile.valid?).to eq false
        expect(profile.errors[:dob]).to eq ["cant be in future"]
      end
    end
  end

  context 'update_document_label' do
    let!(:create_member_permission) do
      create :permission,
              role: 'member'
    end

    let!(:user) { create(:user) }
    let!(:user_without_document) { create(:user) }
    let!(:document_verified_level) { Level.find(4) }
    let!(:document_verified_label) { create_label_with_level(user, document_verified_level) }

    let!(:profile_params) {
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

    it 'change document state when new profile created' do
      expect(user.labels.find_by(key: :document).value).to eq 'verified'

      Profile.create(profile_params.merge(user_id: user.id))
      expect(user.labels.count).to eq 2
      expect(user.labels.find_by(key: :document).value).to eq 'verified'
    end

    it 'do not change document state when document doesnt exist' do
      expect(user_without_document.labels.find_by(key: :document)).to eq nil

      Profile.create(profile_params.merge(user_id: user_without_document.id))
      expect(user_without_document.labels.count).to eq 1
      expect(user_without_document.labels.find_by(key: :document)).to eq nil
    end
  end

  context 'event api behaviour' do
    let!(:permission) { create(:permission, role: 'member') }
    let!(:user) { create(:user, state: 'pending', role: 'member') }
    let!(:profile) { create(:profile, user_id: user.id, first_name: old_name) }
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

  context 'validation' do
    let!(:create_member_permission) do
      create :permission,
              role: 'member'
    end

    context 'encrypted fields length' do
      let!(:profile) { create(:profile) }

      it 'encrypted first name should be valid with 255 characters' do
        profile.update(first_name: Faker::Alphanumeric.alphanumeric(number: 255))

        expect(profile.valid?).to eq true
      end

      it 'encrypted last name should be valid with 255 characters' do
        profile.update(last_name: Faker::Alphanumeric.alphanumeric(number: 255))

        expect(profile.valid?).to eq true
      end

      it 'encrypted address should be valid with 255 characters' do
        profile.update(address: Faker::Alphanumeric.alphanumeric(number: 255))

        expect(profile.valid?).to eq true
      end
    end
  end

  context 'submasked fields' do
    let!(:create_member_permission) do
      create :permission,
              role: 'member'
    end

    let!(:user) { create(:user) }

    let!(:profile) do
      create :profile, first_name: 'Oleksandr',
                       last_name: 'Berezniy',
                       city: 'New  York',
                       postcode: 'AB 135-144',
                       dob: Date.new(2007, 5, 12)
    end

    let!(:profile_without_last_name) do
      create :profile, first_name: 'Oleksandr',
                       last_name: nil,
                       city: 'New  York',
                       postcode: 'AB 135-144'
    end

    let!(:profile_without_dob) do
      create :profile, first_name: 'Oleksandr',
                       last_name: nil,
                       city: 'New  York',
                       postcode: 'AB 135-144',
                       dob: nil
    end

    context 'last_name' do
      it { expect(profile.sub_masked_last_name).to eq 'B*******' }

      it 'should mask all letters except first one' do
        profile.update(last_name: 'Teylor_1')
        expect(profile.sub_masked_last_name).to eq 'T*******'
      end

      it 'should mask all letters except first one' do
        profile.update(last_name: ' Last name ')
        expect(profile.sub_masked_last_name).to eq 'L********'
      end

      it 'should mask all letters except first one' do
        profile.update(last_name: '')
        expect(profile.sub_masked_last_name).to eq ''
      end

      it 'should mask all letters except first one' do
        expect(profile_without_last_name.sub_masked_last_name).to eq nil
      end
    end

    context 'dob' do
      it { expect(profile.sub_masked_dob).to eq '2007-05-**' }

      it 'should mask only date numbers' do
        profile.update(dob: Date.new(2020, 12, 12))
        expect(profile.sub_masked_dob).to eq '2020-12-**'
      end

      it 'should mask only date numbers' do
        expect(profile_without_dob.sub_masked_dob).to eq nil
      end
    end
  end
end
