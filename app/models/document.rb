class Document < ApplicationRecord
  mount_uploader :upload, UploadUploader

  belongs_to :profile
  validates :doc_type, :doc_number, :doc_expire, :upload, presence: true

  validates :doc_number, length: { maximum: 128 }
  validates_format_of :doc_expire,
                      with: /\d{4}\-\d{2}\-\d{2}/,
                      message: 'Date must be in the following format: yyyy-mm-dd'
end

# == Schema Information
# Schema version: 20180126130155
#
# Table name: documents
#
#  id         :integer          not null, primary key
#  profile_id :integer
#  upload     :string(255)
#  doc_type   :string(255)
#  doc_number :string(255)
#  doc_expire :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_documents_on_profile_id  (profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#
