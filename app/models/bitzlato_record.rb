class BitzlatoRecord < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :bitzlato
end
