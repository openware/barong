# frozen_string_literal: true

# Map Label with corresponding key:value to account level
class LevelMapping < ApplicationRecord
  validates :account_level, :label_key, :label_value, presence: true

  validates :label_value, uniqueness: { scope: :label_key }
end

# == Schema Information
# Schema version: 20180425114738
#
# Table name: level_mappings
#
#  id            :integer          not null, primary key
#  account_level :integer          not null
#  label_key     :string(255)      not null
#  label_value   :string(255)      not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_level_mappings_on_label_key_and_label_value  (label_key,label_value) UNIQUE
#
