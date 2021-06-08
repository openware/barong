class BitzlatoUser < BitzlatoRecord
  self.table_name = :users

  scope :by_email, ->(email) { where real_email: email }

  has_one :user_profile, class_name: 'BitzlatoUserProfile', foreign_key: :user_id
end
