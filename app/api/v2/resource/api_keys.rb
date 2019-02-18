# frozen_string_literal: true

module API::V2
  module Resource
    # Responsible for CRUD for api keys
    class APIKeys < Grape::API
      resource :api_keys do
        before do
          unless current_user.otp
            error!({ errors: ['resource.api_key.2fa_disabled'] }, 400)
          end
          error!({ errors: ['resource.api_key.missing_otp'] }, 422) unless params[:totp_code].present?

          unless TOTPService.validate?(current_user.uid, params[:totp_code])
            error!({ errors: ['resource.api_key.invalid_otp'] }, 422)
          end
        end

        desc 'Create an api key',
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :algorithm, type: String, allow_blank: false
          optional :kid, type: String, allow_blank: false
          optional :scope, type: String,
                           allow_blank: false,
                           desc: 'comma separated scopes'
          requires :totp_code, type: String, desc: 'Code from Google Authenticator', allow_blank: false
        end
        post do
          declared_params = declared(unified_params, include_missing: false)
                            .except(:totp_code)
                            .merge(scope: params[:scope]&.split(','))
          api_key = current_user.api_keys.create(declared_params)
          if api_key.errors.any?
            # FIXME: active record validation
            error!(api_key.errors.full_messages.to_sentence, 422)
          end

          present api_key, with: Entities::APIKey
        end

        desc 'Updates an api key',
        security: [{ "BearerToken": [] }],
        failure: [
          { code: 400, message: 'Required params are empty' },
          { code: 401, message: 'Invalid bearer token' },
          { code: 404, message: 'Record is not found' },
          { code: 422, message: 'Validation errors' }
        ]
        params do
          requires :kid, type: String, allow_blank: false
          optional :scope, type: String,
                           allow_blank: false,
                           desc: 'comma separated scopes'
          optional :state, type: String, desc: 'State of API Key. "active" state means key is active and can be used for auth',
                           allow_blank: false
          requires :totp_code, type: String, desc: 'Code from Google Authenticator', allow_blank: false
        end
        patch ':kid' do
          declared_params = declared(params, include_missing: false)
                            .except(:totp_code)
                            .merge(scope: params[:scope]&.split(','))
          api_key = current_user.api_keys.find_by!(kid: params[:kid])

          unless api_key.update(declared_params)
            # FIXME: active record validation
            error!(api_key.errors.full_messages.to_sentence, 422)
          end

          present api_key, with: Entities::APIKey, except: [:secret]
        end

        desc 'Delete an api key',
              security: [{ "BearerToken": [] }],
              success: { code: 204, message: 'Succefully deleted' },
              failure: [
                { code: 400, message: 'Required params are empty' },
                { code: 401, message: 'Invalid bearer token' },
                { code: 404, message: 'Record is not found' }
              ]
        params do
          requires :kid, type: String, allow_blank: false
          requires :totp_code, type: String, desc: 'Code from Google Authenticator', allow_blank: false
        end
        delete ':kid' do
          api_key = current_user.api_keys.find_by!(kid: params[:kid])
          api_key.destroy
          status 204
        end

        desc 'List all api keys for current account.',
        security: [{ "BearerToken": [] }],
        failure: [
          { code: 400, message: 'Require 2FA and totp code' },
          { code: 401, message: 'Invalid bearer token' }
        ]
        params do
          requires :totp_code, type: String, desc: 'Code from Google Authenticator', allow_blank: false
        end
        get do
          present current_user.api_keys, with: Entities::APIKey, except: [:secret]
        end
      end
    end
  end
end
