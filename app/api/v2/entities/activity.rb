# frozen_string_literal: true

module API::V2
  module Entities
    class Activity < API::V2::Entities::Base
      expose :id,
             documentation: {
              type: 'Integer',
              desc: 'Activity ID'
             }

      expose :user_ip,
             documentation: {
              type: 'String',
              desc: 'User IP'
             }

      expose :user_ip_country,
             documentation: {
              type: 'String',
              desc: 'User IP country'
             }

      expose :user_agent,
             documentation: {
              type: 'String',
              desc: 'User Browser Agent'
             }

      expose :topic,
             documentation: {
              type: 'String',
              desc: 'Defined topic (session, adjustments) or general by default'
             }

      expose :action,
             documentation: {
              type: 'String',
              desc: "API action: POST => 'create', PUT => 'update', GET => 'read', DELETE => 'delete', PATCH => 'update' or system if there is no match of HTTP method" 
             }

      expose :result,
             documentation: {
              type: 'String',
              desc: 'Status of API response: succeed, failed, denied'
             }

      expose :data,
             documentation: {
              type: 'String',
              desc: 'Parameters which was sent to specific API endpoint'
             }

      with_options(format_with: :iso_timestamp) do
        expose :created_at
      end
    end
  end
end
