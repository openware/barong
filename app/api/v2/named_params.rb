# frozen_string_literal: true

module API
  module V2
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

      params :timeperiod_filters do
        optional :from,
                 type: Integer,
                 desc: 'An integer represents the seconds elapsed since Unix epoch.'\
                   'If set, only records FROM the time will be retrieved.'
        optional :to,
                 type: Integer,
                 desc: 'An integer represents the seconds elapsed since Unix epoch.'\
                   'If set, only records BEFORE the time will be retrieved.'
      end
    end
  end
end
