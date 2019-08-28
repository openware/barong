# frozen_string_literal: true

# Data json validation
class DataIsJsonValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, data)
    return if data.nil?

    unless validate_data_is_json!(data)
      record.errors.add(attribute, :invalid_format, message: 'data is not json compatible string')
    end
  end

  def validate_data_is_json!(data)
    begin
      JSON.parse(data)
      true
    rescue JSON::ParserError => e
      false
    end
  end
end
