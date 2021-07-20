class PublicAddress < ApplicationRecord
  UID_PREFIX = 'PA'

  validate :role_exists
  validates :uid, presence: true, uniqueness: true

  before_validation :assign_uid

  def as_payload
    as_json(only: %i[uid role level state])
  end

  def role_exists
    return if Permission.pluck(:role).include?(role)

    errors.add(:role, 'doesnt_exist')
  end

  private

  def assign_uid
    return unless uid.blank?

    self.uid = UIDGenerator.generate(UID_PREFIX)
  end
end

# == Schema Information
# Schema version: 20210630090934
#
# Table name: public_addresses
#
#  id         :bigint           not null, primary key
#  uid        :string(255)      not null
#  role       :string(255)      not null
#  address    :string(255)      not null
#  level      :integer          default(1), not null
#  state      :string(255)      default("active"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
