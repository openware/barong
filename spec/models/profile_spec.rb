# frozen_string_literal: true

ENV['SENDER_EMAIL'] = 'test@barong.test'

RSpec.describe Profile, type: :model do
  ## Test of relationships
  it { should belong_to(:account) }
end
