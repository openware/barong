class BitzlatoRecord < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :"bitzlato_#{Rails.env}"
end
