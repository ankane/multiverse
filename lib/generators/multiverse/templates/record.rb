class <%= name.camelize %>Record < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :"<%= name.underscore %>_#{Rails.env}"
end
