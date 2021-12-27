class BitzlatoUser < BitzlatoRecord
  self.table_name = :user

  scope :by_email, ->(email) { where real_email: email }

  has_one :user_profile, class_name: 'BitzlatoUserProfile', foreign_key: :user_id
  has_many :user_features, class_name: 'BitzlatoUserFeature', foreign_key: :user_id

  def self.find_by_email(email)
    by_email(email).where(email_verified: true, deleted_at: nil).take
  end

  def self.find_by_claims(sub: , email: )
    find_by_subject(sub) || find_by_email(email)
  end

  # Posible values are:
  #
  # tgid:
  # uid:
  # email:
  # nickname:
  # email_verified:
  # locale:
  #
  def as_payload
    as_json(only: %i[uid])
  end
end
