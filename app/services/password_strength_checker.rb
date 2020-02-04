# frozen_string_literal: true

# password entropy calculation
class PasswordStrengthChecker
  class <<self
    # this method typically called by validate! from model and from API /pass/validate controller
    def calculate_entropy(password)
      @checker ||= StrongPassword::StrengthChecker.new(min_entropy: Barong::App.config.password_min_entropy,
                                                       use_dictionary: Barong::App.config.password_use_dictionary)
      @checker.calculate_entropy(password)
    end

    # User model invokes this method while validating password on create and update
    def validate!(password)
      password_regex = Barong::App.config.password_regexp
      return 'requirements' unless password_regex.match(password)

      return 'weak' if calculate_entropy(password) < Barong::App.config.password_min_entropy

      'strong'
    end
  end
end
