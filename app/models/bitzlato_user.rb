class BitzlatoUser < BitzlatoRecord
  self.table_name = :users

  scope :by_email, ->(email) { where real_email: email }

  has_one :user_profile, class_name: 'BitzlatoUserProfile', foreign_key: :user_id
  has_many :user_features, class_name: 'BitzlatoUserFeature', foreign_key: :user_id

  def self.find_by_email(email)
    by_email(email).where(email_verified: true, deleted_at: nil).take
  end
end
