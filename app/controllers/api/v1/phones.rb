# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module API
  module V1
    class Phones < Grape::API
      helpers Doorkeeper::Grape::Helpers

      before do
        doorkeeper_authorize!

        def current_account
          @current_account = Account.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
        end

        def phone_valid?(phone_number)
          unless PhoneUtils.valid?(phone_number)
            error!('Phone number is invalid', 400)
            return false
          end

          if Phone.verified.exists?(number: phone_number)
            error!('Phone number is already exists', 400)
            return false
          end
          true
        end
      end

      desc 'Phone related routes'
      resource :phones do
        desc 'Add new phone'
        params do
          requires :phone_number, type: String,
                                  desc: 'Phone number with country code',
                                  allow_blank: false
        end
        post do
          declared_params = declared(params)
          return unless phone_valid?(declared_params[:phone_number])

          phone = current_account.phones.create(number: declared_params[:phone_number])
          error!(phone.errors, 422) if phone.errors.any?

          PhoneUtils.send_confirmation_sms(phone)
        end

        desc 'Verify a phone'
        params do
          requires :phone_number, type: String,
                                  desc: 'Phone number with country code',
                                  allow_blank: false
          requires :verification_code, type: String,
                                       desc: 'Verification code from sms',
                                       allow_blank: false
        end
        post '/verify' do
          declared_params = declared(params)
          return unless phone_valid?(declared_params[:phone_number])

          phone_number = PhoneUtils.sanitize(declared_params[:phone_number])
          phone = current_account.phones.find_by(number: phone_number,
                                                 code: declared_params[:verification_code])

          unless phone
            return error!('Phone is not found or verification code is invalid', 404)
          end

          phone.update(validated_at: Time.current)
          current_account.level_set(:phone)
        end
      end
    end
  end
end
