class Document < ApplicationRecord
  mount_uploader :upload, UploadUploader

  belongs_to :profile
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
