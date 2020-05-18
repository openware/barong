# frozen_string_literal: true

# == Schema Information
#
# Table name: levels
#
#  id          :bigint           not null, primary key
#  key         :string(255)      not null
#  value       :string(255)
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#


require 'rails_helper'

RSpec.describe Level, type: :model do
  it { should validate_presence_of(:key) }
  it { should validate_presence_of(:value) }
  it { should validate_presence_of(:description) }
end
