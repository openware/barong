class Document < ApplicationRecord
end

# == Schema Information
# Schema version: 20180124190951
#
# Table name: documents
#
#  id                  :integer          not null, primary key
#  customer_id         :integer
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
