# frozen_string_literal: true

#
# Class Account
#
class Account < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable
  mount_uploader :doc_photo, AvatarUploader
  mount_uploader :residence_photo, AvatarUploader
  validates :real_name, :document_type, :document_number, :residence_proof, presence: true, if: :check_status?

  def role
    super.inquiry
  end

  def check_status?
    status == true
  end
end

# == Schema Information
# Schema version: 20180124073519
#
# Table name: accounts
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  role                   :string(30)       default("member"), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(255)
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  real_name              :string(255)
#  birth_date             :datetime
#  address                :string(255)
#  city                   :string(255)
#  country                :string(255)
#  zipcode                :string(255)
#  document_type          :string(255)
#  document_number        :string(255)
#  doc_photo              :string(255)
#  residence_proof        :string(255)
#  residence_photo        :string(255)
#  verified               :boolean          default(FALSE)
#  status                 :boolean          default(FALSE)
#
# Indexes
#
#  index_accounts_on_confirmation_token    (confirmation_token) UNIQUE
#  index_accounts_on_email                 (email) UNIQUE
#  index_accounts_on_reset_password_token  (reset_password_token) UNIQUE
#  index_accounts_on_unlock_token          (unlock_token) UNIQUE
#
