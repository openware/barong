class Document < ApplicationRecord
  belongs_to :profile
end

# == Schema Information
# Schema version: 20180125231014
#
# Table name: documents
#
#  id                  :integer          not null, primary key
#  profile_id          :integer
#  upload_id           :string(255)
#  upload_filename     :string(255)
#  upload_content_size :string(255)
#  upload_content_type :string(255)
#  doc_type            :string(255)
#  doc_number          :string(255)
#  doc_expire          :date
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_documents_on_profile_id  (profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#
