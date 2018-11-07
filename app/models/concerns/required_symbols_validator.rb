class RequiredSymbolsValidator < ActiveModel::EachValidator
  
  def validate_each(subject, attribute, value)
    password_regex = /^(?=.*[[:lower:]])(?=.*[[:upper:]])(?=.*[[:digit:]])(?=.*[[:graph:]]).{8,80}$/
    subject.errors.add(attribute, 'does not meet the minimum requirements') unless password_regex.match(value)
  end

end
