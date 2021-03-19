# frozen_string_literal: true

class Platform < ApplicationRecord
  def self.platform_by_host(host)
    return if Platform.count == 0

    Platform.find_by!(hostname: host)
  rescue StandardError
    Rails.logger.fatal("There is no hostname registered")
    raise 'Hostname is not registered'
  end
end

# == Schema Information
# Schema version: 20210315090451
#
# Table name: platforms
#
#  id          :bigint           not null, primary key
#  platform_id :string(255)      not null
#  hostname    :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
