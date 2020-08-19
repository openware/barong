# frozen_string_literal: true

module API::V2
  module Resource
    class Providers < Grape::API
      helpers ::API::V2::NamedParams
      helpers do
        def otp_protected!
          unless current_user.otp
            error!({ errors: ['resource.providers.2fa_disabled'] }, 400)
          end
          error!({ errors: ['resource.providers.missing_totp'] }, 422) unless params[:totp_code].present?

          return if TOTPService.validate?(current_user.uid, params[:totp_code])

          error!({ errors: ['resource.providers.invalid_totp'] }, 422)
        end
      end

      resource :providers do
        desc 'List all service accounts for current provider.',
        security: [{ "BearerToken": [] }],
        failure: [
          { code: 400, message: 'Require 2FA and totp code' },
          { code: 401, message: 'Invalid bearer token' }
        ]
        params do
        end
        get 'service_accounts' do
          current_user.service_accounts
        end

        resource :api_keys do
          desc 'List all api keys for specific service_account.',
          security: [{ "BearerToken": [] }],
          failure: [
            { code: 400, message: 'Require 2FA and totp code' },
            { code: 401, message: 'Invalid bearer token' }
          ]
          params do
            optional :ordering,
                    values: { value: -> (p){ %w[asc desc].include?(p) }, message: 'resource.providers.invalid_ordering' },
                    default: 'asc',
                    desc: 'If set, returned values will be sorted in specific order, defaults to \'asc\'.'
            optional :order_by,
                    values: { value: -> (p){ APIKey.new.attributes.keys.include?(p) }, message: 'resource.providers.invalid_attribute' },
                    default: 'id',
                    desc: 'Name of the field, which result will be ordered by.'
            use :pagination_filters
            requires :service_account_uid, type: { value: String, message: 'resource.provider.non_string_service_account_uid' }
          end
          get do
            target_service_account = current_user.service_accounts.find_by(uid: params[:service_account_uid])

            error!({ errors: ['resource.service_accounts.doesnt_exist'] }, 404) if target_service_account.nil?

            target_service_account.api_keys.order(params[:order_by] => params[:ordering]).tap { |q| present paginate(q), with: Entities::APIKey, except: [:secret] }
          end

          desc 'Create api key for specific service_account.',
          security: [{ "BearerToken": [] }],
          failure: [
            { code: 400, message: 'Require 2FA and totp code' },
            { code: 401, message: 'Invalid bearer token' }
          ]
          params do
            requires :service_account_uid, type: { value: String, message: 'resource.provider.non_string_service_account_uid' }
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
                    message: 'resource.providers.missing_totp',
                    allow_blank: false,
                    desc: 'Code from Google Authenticator'
          end
          post do
            target_service_account = current_user.service_accounts.find_by(uid: params[:service_account_uid])

            error!({ errors: ['resource.service_accounts.doesnt_exist'] }, 404) if target_service_account.nil?

            otp_protected!
            declared_params = declared(unified_params, include_missing: false)
                              .except(:totp_code)
                              .merge(scope: params[:scope]&.split(','))
                              .merge(secret: SecureRandom.hex(16))


            api_key = target_service_account.api_keys.new(declared_params)

            APIKey.transaction do
              raise ActiveRecord::Rollback unless api_key.save
            rescue Vault::VaultError
              api_key.errors.add(:api_key, 'could_not_save_secret')
              raise ActiveRecord::Rollback
            end

            if api_key.errors.any?
              code_error!(api_key.errors.details, 422)
            end

            present api_key, with: Entities::APIKey
          end

          desc 'Delete an api key for specific service account',
            security: [{ "BearerToken": [] }],
            success: { code: 204, message: 'Succefully deleted' },
            failure: [
              { code: 400, message: 'Required params are empty' },
              { code: 401, message: 'Invalid bearer token' },
              { code: 404, message: 'Record is not found' }
            ]
          params do
            requires :service_account_uid, type: { value: String, message: 'resource.provider.non_string_service_account_uid' }
            requires :kid,
                    type: String,
                    allow_blank: false
            requires :totp_code,
                    type: String,
                    allow_blank: false,
                    desc: 'Code from Google Authenticator'
          end
          delete ':kid' do
            target_service_account = current_user.service_accounts.find_by(uid: params[:service_account_uid])

            error!({ errors: ['resource.service_accounts.doesnt_exist'] }, 404) if target_service_account.nil?

            otp_protected!
            api_key = target_service_account.api_keys.find_by!(kid: params[:kid])
            api_key.destroy
            status 204
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
            requires :service_account_uid, type: { value: String, message: 'resource.provider.non_string_service_account_uid' }
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
          put ':kid' do
            target_service_account = current_user.service_accounts.find_by(uid: params[:service_account_uid])

            error!({ errors: ['resource.service_accounts.doesnt_exist'] }, 404) if target_service_account.nil?

            otp_protected!
            declared_params = declared(params, include_missing: false)
                              .except(:totp_code).except(:service_account_uid)
                              .merge(scope: params[:scope]&.split(','))
            api_key = target_service_account.api_keys.find_by!(kid: params[:kid])
            unless api_key.update(declared_params)
              code_error!(api_key.errors.details, 422)
            end
  
            present api_key, with: Entities::APIKey, except: [:secret]
          end
        end
      end
    end
  end
end
