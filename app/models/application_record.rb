class ApplicationRecord < ActiveRecord::Base

  include Iso8601TimeFormat

  self.abstract_class = true
end
