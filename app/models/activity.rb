class Activity < ApplicationRecord
  RESULTS = %w[succeed failed denied].freeze
  CATEGORIES = %w[admin user].freeze

  belongs_to :user
  has_one :target, primary_key: :target_uid, foreign_key: :uid, class_name: 'User'

  validates :user_ip, presence: true, allow_blank: false
  validates :user_agent, presence: true, trusty_agent: true
  validates :topic, presence: true
  validates :result, presence: true, inclusion: { in: RESULTS }
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validate :target_user

  # this method allows to use all the methods of ::Browser module (platofrm, modern?, version etc)
  def browser
    Browser.new(user_agent)
  end

  private

  def target_user
    errors.add(:target_uid, :invalid) if target_uid.present? && User.where(uid: target_uid).empty?
    errors.add(:target_uid, :not_allowed) if target_uid.present? && category.present? && category == 'user'
  end

  def readonly?
    !new_record?
  end
end
