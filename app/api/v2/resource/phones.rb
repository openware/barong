# frozen_string_literal: true

module API::V2
  module Resource
    class Phones < Grape::API
      rescue_from(Twilio::REST::RestError) do |error|
        Rails.logger.error "Twilio Client Error: #{error.message}"
        error!({ errors: ['resource.phone.twillio'] }, 500)
      end

      helpers do
        def validate_phone!(phone_number)
          phone_number = Phone.international(phone_number)

          error!({ errors: ['resource.phone.invalid_num'] }, 400) \
            unless Phone.valid?(phone_number)

              error!({ errors: ['resource.phone.number_exist'] }, 400) \
            if Phone.verified.exists?(number: phone_number)
        end
      end

      desc 'Phone related routes'
      resource :phones do
        desc 'Returns list of user\'s phones',
              security: [{ "BearerToken": [] }],
              failure: [
                { code: 401, message: 'Invalid bearer token' },
              ]
        get do
          present current_user.phones, with: Entities::Phone
        end

        desc 'Add new phone',
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 404, message: 'Record is not found' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :phone_number,
                   type: String,
                   allow_blank: false,
                   desc: 'Phone number with country code'
        end
        post do
          declared_params = declared(params)
          validate_phone!(declared_params[:phone_number])

          phone_number = Phone.international(declared_params[:phone_number])
          error!({errors: ['resource.phone.exists']}, 400) if current_user.phones.exists?(number: phone_number)

          phone = current_user.phones.create(number: phone_number)
          code_error!(phone.errors.details, 422) if phone.errors.any?

          Phone.send_confirmation_sms(phone)
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
          requires :phone_number,
                   type: String,
                   allow_blank: false,
                   desc: 'Phone number with country code'
        end
        post '/send_code' do
          declared_params = declared(params)
          validate_phone!(declared_params[:phone_number])

          phone_number = Phone.international(declared_params[:phone_number])
          phone = current_user.phones.find_by!(number: phone_number)
          code_error!(phone.errors.details, 422) unless phone.regenerate_code

          Phone.send_confirmation_sms(phone)
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
          requires :phone_number,
                   type: String,
                   allow_blank: false,
                   desc: 'Phone number with country code'
          requires :verification_code,
                   type: String,
                   allow_blank: false,
                   desc: 'Verification code from sms'
        end
        post '/verify' do
          declared_params = declared(params)
          validate_phone!(declared_params[:phone_number])

          phone_number = Phone.international(declared_params[:phone_number])
          phone = current_user.phones.find_by(number: phone_number,
                                                 code: declared_params[:verification_code])

          error!({ errors: ['resource.phone.verification_invalid'] }, 404) unless phone

          phone.update(validated_at: Time.current)
          current_user.add_level_label(:phone)
          { message: 'Phone was verified successfully' }
        end
      end
    end
  end
end
