# frozen_string_literal: true

module API
  module V2
    module Admin
      module NamedParams
        extend ::Grape::API::Helpers

        params :pagination_filters do
          optional :page,
            type: { value: Integer, message: 'non_integer_page' },
            values: { value: -> (p){ p.try(:positive?) }, message: 'non_positive_page'},
            default: 1,
            desc: 'Page number (defaults to 1).'
          optional :limit,
            type: { value: Integer, message: 'non_integer_limit' },
            values: { value: 1..100, message: 'invalid_limit' },
            default: 100,
            desc: 'Number of users per page (defaults to 100, maximum is 100).'
        end

        params :activity_attributes do
          optional :topic,
                   type: { value: String, message: 'admin.activity.non_string_topic' }
          optional :action,
                   type: { value: String, message: 'admin.activity.non_string_action' }
          optional :uid,
                   type: { value: String, message: 'admin.activity.non_string_uid' }
          optional :email,
                   type: { value: String, message: 'admin.activity.non_string_email' }
        end
      end
    end
  end
end
