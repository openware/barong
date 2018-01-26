# frozen_string_literal: true

#
# Class Phone
#
class Phone < ApplicationRecord
  belongs_to :account

  validates :number, phone: true
end

# == Schema Information
# Schema version: 20180123155346
#
# Table name: phones
#
#  id           :integer          not null, primary key
#  country      :string(255)
#  number       :string(255)      not null
#  validated_at :datetime
#  account_id   :integer          unsigned, not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_phones_on_account_id  (account_id)
#  index_phones_on_number      (number) UNIQUE
#
