# frozen_string_literal: true

RSpec.describe LevelMapping, type: :model do
  it { should validate_presence_of(:account_level) }
  it { should validate_presence_of(:label_key) }
  it { should validate_presence_of(:label_value) }
end
