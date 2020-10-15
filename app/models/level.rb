# frozen_string_literal: true

# Label level mapping model
class Level < ApplicationRecord
  validates :key, :value, :description, presence: true
  validates :value, uniqueness: { scope: :key }
end

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
