class Document < ApplicationRecord
  mount_uploader :doc_file_name, UploadUploader
  mount_uploader :doc_file_name_2, UploadUploader

  belongs_to :profile
  validates :doc_type, :doc_number, presence: { :message => "is required."}
  validates :doc_number, length: { maximum: 128 }
  validates :doc_state, presence:{ :message => "is required."}, :if => "doc_type == 'DL'"
  validates :doc_file_name, presence: { :message => "is required."}, length: { maximum: 10.megabytes, allow_blank: true }
  validates :doc_file_name_2, presence:{ :message => "is required."}, :if => "doc_type == 'DL'", length: { maximum: 10.megabytes, allow_blank: true }
end

# == Schema Information
# Schema version: 20180222010938
#
# Table name: documents
#
#  id              :integer          not null, primary key
#  profile_id      :integer
#  doc_file_name   :string(255)
#  doc_file_name_2 :string(255)
#  doc_type        :string(255)
#  doc_number      :string(255)
#  doc_state       :string(255)
#  green_id_status :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_documents_on_profile_id  (profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#
