# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Level, type: :model do
  it { should validate_presence_of(:key) }
  it { should validate_presence_of(:value) }
  it { should validate_presence_of(:description) }
end
