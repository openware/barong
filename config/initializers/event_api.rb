# frozen_string_literal: true

require_dependency 'barong/event_api'

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.include ::EventAPI::ActiveRecord::Extension
end
