# frozen_string_literal: true

# Convert time to utc 8601
module Iso8601TimeFormat
  extend ActiveSupport::Concern

  def format_iso8601_time(time)
    utc_time = time.respond_to?(:utc) ? time.utc : time
    utc_time&.iso8601
  end
end
