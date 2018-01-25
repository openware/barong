class Customer < ApplicationRecord

  has_many :documents, dependent: :destroy

  belongs_to :account

end
# == Schema Information
# Schema version: 20180124190951
#
# Table name: customers
#
#  id         :integer          not null, primary key
#  first_name :string(255)      not null
#  last_name  :string(255)      not null
#  address    :string(255)
#  postcode   :string(255)
#  city       :string(255)
#  country    :string(255)
#  dob        :date
#  account_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_customers_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#

#  updated_at :datetime         not null
