# frozen_string_literal: true

module API::V2
  module Resource
    # Responsible for CRUD for api keys
    class APIKeys < Grape::API
      helpers do
        def otp_protected!
          unless current_user.otp
            error!({ errors: ['resource.api_key.2fa_disabled'] }, 400)
          end
          error!({ errors: ['resource.api_key.missing_totp'] }, 422) unless params[:totp_code].present?

          return if TOTPService.validate?(current_user.uid, params[:totp_code])

          error!({ errors: ['resource.api_key.invalid_totp'] }, 422)
        end
      end

      resource :api_keys do
        desc 'Create an api key',
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :algorithm,
                   type: String,
                   allow_blank: false
          optional :kid,
                   type: String,
                   allow_blank: false
          optional :scope,
                   type: String,
                   allow_blank: false,
                   desc: 'comma separated scopes'
          requires :totp_code,
                   type: String,
                   message: 'resource.api_key.missing_totp',
                   allow_blank: false,
                   desc: 'Code from Google Authenticator'
        end
        post do
          otp_protected!
          declared_params = declared(unified_params, include_missing: false)
                            .except(:totp_code)
                            .merge(scope: params[:scope]&.split(','))

          api_key = current_user.api_keys.new(declared_params)

          APIKey.transaction do
            raise ActiveRecord::Rollback unless api_key.save
            SecretStorage.store_secret(SecureRandom.hex(16), api_key.kid)
          rescue SecretStorage::Error
            api_key.errors.add(:api_key, 'could_not_save_secret')
            raise ActiveRecord::Rollback
          end

          if api_key.errors.any?
            code_error!(api_key.errors.details, 422)
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
          requires :kid,
                   type: String,
                   allow_blank: false
          optional :scope,
                   type: String,
                   allow_blank: false,
                   desc: 'comma separated scopes'
          optional :state,
                   type: String,
                   allow_blank: false,
                   desc: 'State of API Key. "active" state means key is active and can be used for auth'
          requires :totp_code,
                   type: String,
                   allow_blank: false,
                   desc: 'Code from Google Authenticator'
        end
        patch ':kid' do
          otp_protected!
          declared_params = declared(params, include_missing: false)
                            .except(:totp_code)
                            .merge(scope: params[:scope]&.split(','))
          api_key = current_user.api_keys.find_by!(kid: params[:kid])

          unless api_key.update(declared_params)
            code_error!(api_key.errors.details, 422)
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
          requires :kid,
                   type: String,
                   allow_blank: false
          requires :totp_code,
                   type: String,
                   allow_blank: false,
                   desc: 'Code from Google Authenticator'
        end
        delete ':kid' do
          otp_protected!
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
          optional :page,      type: Integer, default: 1,   integer_gt_zero: true, desc: 'Page number (defaults to 1).'
          optional :limit,     type: Integer, default: 100, range: 1..1000, desc: 'Number of api keys per page (defaults to 100, maximum is 1000).'
        end
        get do
          current_user.api_keys.tap { |q| present paginate(q), with: Entities::APIKey, except: [:secret] }
        end
      end
    end
  end
end
