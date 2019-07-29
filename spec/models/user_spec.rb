# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  context 'User model basic syntax' do
    ## Test of validations
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
    it { should have_many(:documents).dependent(:destroy) }

    ## Test of relationships
    it { should have_one(:profile).dependent(:destroy) }

    ## Test of UID creation
    it 'creates default uid with prefix ID' do
      default_user = create(:user)
      expect(default_user.uid).to start_with(ENV.fetch('BARONG_UID_PREFIX', 'ID'))
    end

    it 'uid prefix can be changed by ENV' do
      allow(Barong::App.config).to receive(:barong_uid_prefix).and_return('GG')

      default_user = create(:user)
      expect(default_user.uid).to start_with('GG')
    end

    it 'uid_prefix doesnt case sensitive and always converts to big letters' do
      allow(Barong::App.config).to receive(:barong_uid_prefix).and_return('aa')

      default_user = create(:user)
      expect(default_user.uid).to start_with('AA')
    end

    it do
      usr = create(:user)
      payload = usr.as_payload
      expect(payload['email']).to eq(usr.email)
    end

    describe '#referral' do
      let!(:user1) { create(:user) }
      let!(:user2) { create(:user, referral_id: user1.id) }

      it 'return error when referral doesnt exist' do
        record = User.new(uid: 'ID122312323', email: 'test@barong.io', password: 'Oo213Wqw')
        record.referral_id = 0
        record.valid?

        expect(record.errors[:referral_id]).to eq(['doesnt_exist'])
      end

      it 'return refferal uid' do
        expect(user2.referral_uid).to eq user1.uid
      end
    end
  end

  describe '#password' do
    it { should_not allow_value('Password1').for(:password)}
    it { should_not allow_value('Password1123').for(:password)}
    it { should_not allow_value('password').for(:password)}
    it { should_not allow_value('password1').for(:password)}
    it { should_not allow_value('Qq123123').for(:password)}
    it { should_not allow_value('QqQq123123').for (:password)}
    it { should_not allow_value('X2qL32').for(:password)}
    it { should_not allow_value('eoV0qu').for(:password)}
    it { should allow_value('Iequ4geiEWQw').for(:password)}
    it { should allow_value('Xwqe213PZCXwe').for(:password)}
    it { should allow_value('Kal31ewwqXrew').for(:password)}
  end

  let(:uploaded_file) { fixture_file_upload('/files/documents_test.jpg', 'image/jpg') }

  context 'User with 2 or more documents' do
    it do
      user = User.create!(email: 'test@gmail.com', password: 'KeeKi7zoWExzc')
      expect(User.count).to eq 1
      document1 = user.documents.create!(upload: uploaded_file,
                                            doc_type: 'Passport',
                                            doc_number: 'MyString',
                                            doc_expire: '01-01-2020')
      document2 = user.documents.create!(upload: uploaded_file,
                                            doc_type: 'Passport',
                                            doc_number: 'MyString',
                                            doc_expire: '01-02-2020')
      expect(user.reload.documents).to eq([document1, document2])
    end

    after(:all) { User.destroy_all }
  end

  describe 'Iso8601TimeFormat' do
    let!(:user) { create(:user) }
    around(:each) { |example| Time.use_zone('Pacific/Midway') { example.run } }

    it 'parses time in utc and iso8601' do
      expect(user.format_iso8601_time(user.created_at)).to \
        eq user.created_at.utc.iso8601
    end

    it 'skips nil' do
      expect(user.format_iso8601_time(nil)).to eq nil
    end

    it 'parses date to iso8601' do
      expect(user.format_iso8601_time(user.created_at.to_date)).to \
        eq user.created_at.to_date.iso8601
    end
  end
end
