# frozen_string_literal: true

module API
  module V2
    module Admin
      # Admin functionality over jobs table
      class Jobs < Grape::API
        resource :jobs do
          # POST request
          # description - required
          # start_at - required
          # finish_at (optional)
          # type - required (default maintenance)
          # whitelist_ip (optional)
          # Create Job with reference to Restriction +
          # Restriction to whitelist if whitelist_ip present => create Restriction for whitelist specific IP

          # GET request
          # List for existing Jobs with pagination

          # PUT request
          # Update of existing Job mainly it will be used to disable Job and disable reference
          # Also, we can add here the ability to change starts_at and finish_at (Bonus Task)
        end
      end
    end
  end
end
