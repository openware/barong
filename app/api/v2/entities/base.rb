# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Entities
      class Base < Grape::Entity
        format_with(:iso_timestamp) { |t| t.iso8601 if t }
      end
    end
  end
end
