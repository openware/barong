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
