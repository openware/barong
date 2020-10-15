# frozen_string_literal: true

# Data Storage model
class DataStorage < ApplicationRecord
  BLACKLISTED_TITLES = %w[document label profile phone user].freeze
  acts_as_eventable prefix: 'data_storage', on: %i[create update]

  belongs_to :user

  validates :title, :data, presence: true
  validates_length_of :data, maximum: 5120 # maximum 5kb of data
  validates :data, data_is_json: true
  validates :title, uniqueness: { scope: :user_id, case_sensitive: false },
                    inclusion: { in: UserStorageTitles.list }, exclusion: { in: BLACKLISTED_TITLES }

  def as_json_for_event_api
    {
      user: user.as_json_for_event_api,
      title: title,
      data: data,
      created_at: format_iso8601_time(created_at),
      updated_at: format_iso8601_time(updated_at)
    }
  end
end

# == Schema Information
#
# Table name: data_storages
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           unsigned, not null
#  title      :string(64)       not null
#  data       :text(65535)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_data_storages_on_user_id_and_title  (user_id,title) UNIQUE
#
