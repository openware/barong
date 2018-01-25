class Document < ApplicationRecord

  belongs_to :customer

end
# == Schema Information
# Schema version: 20180124190951
#
# Table name: documents
#
#  id                  :integer          not null, primary key
#  upload_id           :string(255)
#  upload_filename     :string(255)
#  upload_content_size :string(255)
#  upload_content_type :string(255)
#  doc_type            :string(255)
#  doc_number          :string(255)
#  doc_expire          :date
#  customer_id         :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_documents_on_customer_id  (customer_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#

#  updated_at          :datetime         not null
