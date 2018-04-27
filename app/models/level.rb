# frozen_string_literal: true

class Level < ApplicationRecord
  validates :key, :value, :description, presence: true
  validates :value, uniqueness: { scope: :key }
  belongs_to :label, foreign_key: :key, primary_key: :key, optional: true
end

# == Schema Information
# Schema version: 20180426105942
#
# Table name: levels
#
#  id          :integer          not null, primary key
#  key         :string(255)
#  value       :string(255)
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
