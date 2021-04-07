# frozen_string_literal: true

module API::V2
  module Management
    module Entities
      class Attachment < API::V2::Entities::Base
        expose :id,
               documentation: {
                 type: 'Integer',
                 desc: 'Activity ID'
               }
        expose :user_uid,
               if: ->(attachment, _options) { attachment.user },
               documentation: {
                 type: 'String',
                 desc: 'User UID'
               } do |attachment|
          attachment.user.uid if attachment.user.present?
        end
      end
    end
  end
end
