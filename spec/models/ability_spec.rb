# frozen_string_literal: true

describe Ability do

  before do
    allow(Ability).to receive(:admin_permissions).and_return({
      "superadmin"=>{"manage"=>["User", "Activity", "Ability", "APIKey", "Profile", "Permission", "Label", "Restriction", "Level"]},
      "admin"=>{"read"=>["Level", "APIKey", "Permission"], "manage"=>["User", "Activity", "Profile", "Label"]},
      "compliance"=>{"read"=>["Level", "User", "Activity"], "manage"=>["Label"], "update"=>["Profile"]},
      "support"=>{"read"=>["User", "Activity", "APIKey", "Profile", "Label", "Level"]}
    })
  end

  let!(:create_permissions) do
    create(:permission, role: 'superadmin', action: 'accept', verb: 'get')
    create(:permission, role: 'admin', action: 'accept', verb: 'get')
    create(:permission, role: 'compliance', action: 'accept', verb: 'get')
    create(:permission, role: 'support', action: 'accept', verb: 'get')
  end

  context 'abilities for superadmin' do
    let(:test_user) { create(:user, email: 'example@gmail.com', role: 'superadmin') }
    subject(:ability) { AdminAbility.new(test_user) }

    it { is_expected.to be_able_to(:manage, User.new) }
    it { is_expected.to be_able_to(:manage, Activity.new) }
    it { is_expected.to be_able_to(:manage, Profile.new) }
    it { is_expected.to be_able_to(:manage, Permission.new) }
    it { is_expected.to be_able_to(:manage, Label.new) }
    it { is_expected.to be_able_to(:manage, Restriction.new) }
    it { is_expected.to be_able_to(:manage, Level.new) }
  end

  context 'abilities for admin' do
    let(:test_user) { create(:user, email: 'example@gmail.com', role: 'admin') }
    subject(:ability) { AdminAbility.new(test_user) }

    it { is_expected.to be_able_to(:read, Level.new) }
    it { is_expected.to be_able_to(:read, APIKey.new) }
    it { is_expected.to be_able_to(:read, Permission.new) }
    it { is_expected.to be_able_to(:manage, User.new) }
    it { is_expected.to be_able_to(:manage, Activity.new) }
    it { is_expected.to be_able_to(:manage, Profile.new) }
    it { is_expected.to be_able_to(:manage, Label.new) }
  end

  context 'abilities for compliance' do
    let(:test_user) { create(:user, email: 'example@gmail.com', role: 'compliance') }
    subject(:ability) { AdminAbility.new(test_user) }


    it { is_expected.to be_able_to(:read, Level.new) }
    it { is_expected.to be_able_to(:read, User.new) }
    it { is_expected.to be_able_to(:read, Activity.new) }
    it { is_expected.to be_able_to(:manage, Label.new) }
    it { is_expected.to be_able_to(:update, Profile.new) }
  end

  context 'abilities for support' do
    let(:test_user) { create(:user, email: 'example@gmail.com', role: 'support') }
    subject(:ability) { AdminAbility.new(test_user) }

    it { is_expected.to be_able_to(:read, User.new) }
    it { is_expected.to be_able_to(:read, Activity.new) }
    it { is_expected.to be_able_to(:read, APIKey.new) }
    it { is_expected.to be_able_to(:read, Profile.new) }
    it { is_expected.to be_able_to(:read, Label.new) }
    it { is_expected.to be_able_to(:read, Level.new) }
  end
end
