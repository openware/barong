# == Schema Information
#
# Table name: comments
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           unsigned, not null
#  author_uid :string(16)       not null
#  title      :string(64)       not null
#  data       :text(65535)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Comment < ApplicationRecord
  belongs_to :user

  validates :title, :data, :author_uid, presence: true
end
