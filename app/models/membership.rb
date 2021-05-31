# frozen_string_literal: true

class Membership < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  scope :with_all_organizations, lambda {
                                   joins('LEFT JOIN organizations ON organizations.id = memberships.organization_id')
                                 }
  scope :with_organizations, ->(id) { where(organization_id: id) }
  scope :with_users, ->(id) { where(user_id: id) }
end

# == Schema Information
# Schema version: 20210514034514
#
# Table name: memberships
#
#  id              :bigint           not null, primary key
#  user_id         :bigint
#  organization_id :bigint           not null
#  role            :string(255)      default("member"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_memberships_on_organization_id  (organization_id)
#  index_memberships_on_user_id          (user_id)
#
