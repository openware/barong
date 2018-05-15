# frozen_string_literal: true

# :nodoc:
class ApplicationRecord < ActiveRecord::Base
  include Iso8601TimeFormat
  self.abstract_class = true
end
