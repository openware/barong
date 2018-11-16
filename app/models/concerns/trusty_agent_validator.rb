class TrustyAgentValidator < ActiveModel::EachValidator
  # Can add any validations and requirements
  def validate_each(record, attribute, value)
    browser = Browser.new(value)
    record.data = 'note: detected suspicious browser' unless browser.known?
  end

end
