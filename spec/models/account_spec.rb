describe Account do
  describe 'validations' do
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

    it { is_expected.to validate_presence_of :uid }
    it { is_expected.to validate_uniqueness_of :uid }

    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_confirmation_of(:password).on(:create) }
  end

  describe 'relations' do
    it { is_expected.to have_one(:profile).dependent(:destroy) }
    it { is_expected.to have_many(:phones).dependent(:destroy) }
  end

  context 'default values' do
    its(:uid)   { is_expected.to be_present  }
    its(:level) { is_expected.to be_zero     }
    its(:role)  { is_expected.to eq 'member' }
  end
end
