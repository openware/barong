class TrustyAgentValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    browser = Browser.new(value)
    unless browser.known?
      record.data = {note: 'Detected suspicious browser'}.to_json 
    end
  end

end
