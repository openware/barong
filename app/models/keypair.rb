# frozen_string_literal: true

# Model Keypair
class Keypair < ApplicationRecord

  validates :label,
            :token,
            presence: true

end

# == Schema Information
# Schema version: 20180306070936
#
# Table name: keypairs
#
#  id         :integer          not null, primary key
#  label      :string(255)
#  token      :string(255)
#  rake_limit :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
