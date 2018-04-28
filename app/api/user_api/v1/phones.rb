# frozen_string_literal: true

module UserApi
  module V1
    class Phones < Grape::API
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
          { message: 'Code was sent successfully' }
        end

        desc 'Resend activation code'
        params do
          requires :phone_number, type: String,
                                  desc: 'Phone number with country code',
                                  allow_blank: false
        end
        post '/send_code' do
          declared_params = declared(params)
          return unless phone_valid?(declared_params[:phone_number])

          phone_number = PhoneUtils.sanitize(declared_params[:phone_number])
          phone = current_account.phones.find_by!(number: phone_number)

          unless phone.regenerate_code
            return error!(phone.errors, 422)
          end

          PhoneUtils.send_confirmation_sms(phone)
          { message: 'Code was sent successfully' }
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

          return error!('Phone is not found or verification code is invalid', 404) unless phone

          phone.update(validated_at: Time.current)
          current_account.add_level_label(:phone)
          { message: 'Phone was verified successfully' }
        end
      end
    end
  end
end
