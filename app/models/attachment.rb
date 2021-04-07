# frozen_string_literal: true

class Attachment < ApplicationRecord
  mount_uploader :upload, Barong::App.config.uploader
  belongs_to :user, optional: true
end

# == Schema Information
# Schema version: 20210407074212
#
# Table name: attachments
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           unsigned
#  upload     :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
