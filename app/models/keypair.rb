# frozen_string_literal: true

# Model Keypair
class Keypair < ApplicationRecord

  validates :label,
            presence: true

end

# == Schema Information
# Schema version: 20180306070936
#
# Table name: keypairs
#
#  id              :integer          not null, primary key
#  label           :string(255)
#  access_key      :string(255)
#  secret_key      :string(255)
#  trusted_ip_list :string(255)
#  scopes          :string(255)
#  expires_at      :datetime
#  deleted_at      :datetime
#  rate_limit      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
