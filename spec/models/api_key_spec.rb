# frozen_string_literal: true

RSpec.describe APIKey, type: :model do
  it { should validate_presence_of(:account_id) }
  it { should validate_presence_of(:public_key) }

  it 'validates expires_in' do
    should validate_numericality_of(:expires_in)
      .only_integer
      .is_greater_than_or_equal_to(30)
      .is_less_than_or_equal_to(24.hours.to_i)
  end
end
