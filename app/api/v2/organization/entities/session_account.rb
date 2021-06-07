# frozen_string_literal: true

module API::V2::Organization
  module Entities
    class SessionAccount < API::V2::Entities::Base
      expose :name do |member|
        member[:name]
      end

      expose :oid do |member|
        member[:oid]
      end

      expose :uid do |member|
        member[:uid]
      end
    end
  end
end
