# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    # Overrides standard AR and grape validation errors
    module ExceptionHandlers
      def self.included(base)
        base.instance_eval do
          rescue_from Grape::Exceptions::ValidationErrors do |e|
            errors_array = e.full_messages.map do |err|
              err.split.last
            end
            error!({ errors: errors_array }, 422)
          end

           rescue_from ActiveRecord::RecordNotFound do |_e|
            error!({ errors: ['record.not_found'] }, 404)
          end

          rescue_from Peatio::Auth::Error do |e|
            # report_exception(e)
            error!({ errors: ['jwt.decode_and_verify'] }, 401)
          end

          rescue_from(JWT::DecodeError) do |error|
            # expired for "Signature has expired"   - expired token
            # segments for "Not enough or too many segments"   - wrong token
            error!({ errors: ["jwt.decode_and_verify.#{error.message.split.last}"] }, 422)
          end

          # Known Vault Error from TOTPService.with_human_error
          rescue_from(TOTPService::Error) do |error|
            error!({ errors: ['totp.error'] }, 422)
          end

          rescue_from :all do |e|
            Rails.logger.error "#{e.message}\n#{e.backtrace[0..5].join("\n")}"
            error!({ errors: ['server.internal_error'] }, 500)
          end
        end
      end
    end
  end
end