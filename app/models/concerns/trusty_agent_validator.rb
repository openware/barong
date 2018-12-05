# frozen_string_literal: true

# User agent validator
class TrustyAgentValidator < ActiveModel::EachValidator
  def validate_each(record, _attribute, value)
    browser = Browser.new(value)
    return if browser.known?

    return record.data = { note: 'Detected suspicious browser' }.to_json if record.data.nil?

    record.data = JSON.parse(record.data).merge(note: 'Detected suspicious browser').to_json
  end
end
