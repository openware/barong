class Comment < ApplicationRecord
  belongs_to :user

  validates :title, :data, :author_uid, presence: true
end
