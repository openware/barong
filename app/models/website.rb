# frozen_string_literal: true

#
# Website
#
class Website < ApplicationRecord
end

# == Schema Information
# Schema version: 20180516142429
#
# Table name: websites
#
#  id           :integer          not null, primary key
#  domain       :string(255)
#  title        :string(255)
#  logo         :string(255)
#  favicon      :string(255)
#  stylesheet   :string(255)
#  header       :text(65535)
#  footer       :text(65535)
#  redirect_url :string(255)
#  state        :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_websites_on_domain  (domain) UNIQUE
#
