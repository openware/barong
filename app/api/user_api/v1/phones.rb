# frozen_string_literal: true

module UserApi
  module V1
    class Phones < Grape::API
      desc 'Phone related routes'
      resource :phones do
        desc 'Add new phone',
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 404, message: 'Record is not found' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :phone_number, type: String,
                                  desc: 'Phone number with country code',
                                  allow_blank: false
        end
        post do
          declared_params = declared(params)
          return unless phone_valid?(declared_params[:phone_number])

          phone_number = PhoneUtils.international(declared_params[:phone_number])
          phone = current_account.phones.create(number: phone_number)
          error!(phone.errors, 422) if phone.errors.any?

          PhoneUtils.send_confirmation_sms(phone)
          { message: 'Code was sent successfully' }
        end

        desc 'Resend activation code',
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 404, message: 'Record is not found' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :phone_number, type: String,
                                  desc: 'Phone number with country code',
                                  allow_blank: false
        end
        post '/send_code' do
          declared_params = declared(params)
          return unless phone_valid?(declared_params[:phone_number])

          phone_number = PhoneUtils.international(declared_params[:phone_number])
          phone = current_account.phones.find_by!(number: phone_number)
          error!(phone.errors, 422) unless phone.regenerate_code

          PhoneUtils.send_confirmation_sms(phone)
          { message: 'Code was sent successfully' }
        end

        desc 'Verify a phone',
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 404, message: 'Record is not found' }
             ]
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

          phone_number = PhoneUtils.international(declared_params[:phone_number])
          phone = current_account.phones.find_by(number: phone_number,
                                                 code: declared_params[:verification_code])

          return error!('Phone is not found or verification code is invalid', 404) unless phone

          phone.update(validated_at: Time.current)
          current_account.add_level_label(:phone)
          { message: 'Phone was verified successfully' }
        end
      end
    end
  end
end
