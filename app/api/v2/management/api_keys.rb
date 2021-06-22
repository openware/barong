# frozen_string_literal: true

module API::V2
  module Management
    class APIKeys < Grape::API
      resource :api_keys do
        desc 'Create an api key for service account' do
          @settings[:scope] = :write_apikeys
          success API::V2::Entities::APIKey
        end
        params do
          requires :algorithm,
                   type: String,
                   allow_blank: false,
                   desc: 'API key algorithm'
          requires :uid,
                   type: String,
                   allow_blank: false,
                   desc: 'User UID or Service Account UID'
          optional :scopes,
                   type: String,
                   allow_blank: false,
                   desc: 'Comma separated scopes'
        end
        post do
          if params[:uid].start_with?(Barong::App.config.uid_prefix)
            error!({ error: 'disabled_management_endpoint' }, 422) unless Barong::App.config.mgn_api_keys_user

            key_holder = User.find_by(uid: params[:uid])
            error!({ error: 'user_doesnt_exist' }, 422) unless key_holder
          elsif params[:uid].start_with?(ServiceAccount::UID_PREFIX)
            error!({ error: 'disabled_management_endpoint' }, 422) unless Barong::App.config.mgn_api_keys_sa

            key_holder = ServiceAccount.find_by(uid: params[:uid])
            error!({ error: 'service_account_doesnt_exist' }, 422) unless key_holder
          else
            error!({ error: 'uid_prefix_doesnt_exist'}, 422)
          end

          declared_params = declared(params, include_missing: false)
                              .except(:uid, :scopes)
                              .merge(scope: params[:scopes]&.split(','))
                              .merge(secret: SecureRandom.hex(16))

          api_key = key_holder.api_keys.new(declared_params)

          APIKey.transaction do
            raise ActiveRecord::Rollback unless api_key.save
          rescue Vault::VaultError
            api_key.errors.add(:api_key, 'could_not_save_secret')
            raise ActiveRecord::Rollback
          end

          code_error!(api_key.errors.details, 422) if api_key.errors.any?

          present api_key, with: API::V2::Entities::APIKey
        end

        desc 'Updates an api key for service account' do
          @settings[:scope] = :write_apikeys
          success API::V2::Entities::APIKey
        end
        params do
          requires :kid,
                   type: String,
                   allow_blank: false,
                   desc: 'API key kid'
          requires :uid,
                   type: String,
                   allow_blank: false,
                   desc: 'Service Account UID'
          optional :scopes,
                   type: String,
                   allow_blank: false,
                   desc: 'Comma separated scopes'
          optional :state,
                   type: String,
                   allow_blank: false,
                   desc: 'State of API Key. "active" state means key is active and can be used for auth'
        end
        post '/update' do
          if params[:uid].start_with?(Barong::App.config.uid_prefix)
            error!({ error: 'disabled_management_endpoint' }, 422) unless Barong::App.config.mgn_api_keys_user

            key_holder = User.find_by(uid: params[:uid])
            error!({ error: 'user_doesnt_exist' }, 422) unless key_holder
          elsif params[:uid].start_with?(ServiceAccount::UID_PREFIX)
            error!({ error: 'disabled_management_endpoint' }, 422) unless Barong::App.config.mgn_api_keys_sa

            key_holder = ServiceAccount.find_by(uid: params[:uid])
            error!({ error: 'service_account_doesnt_exist' }, 422) unless key_holder
          else
            error!({ error: 'uid_prefix_doesnt_exist'}, 422)
          end

          declared_params = declared(params, include_missing: false)
                              .except(:uid, :scopes)
                              .merge(scope: params[:scopes]&.split(','))

          api_key = key_holder.api_keys.find_by(kid: params[:kid])
          error!({ error: 'api_key_doesnt_exist' }, 422) unless api_key

          code_error!(api_key.errors.details, 422) unless api_key.update(declared_params)

          present api_key, with: API::V2::Entities::APIKey, except: [:secret]
        end
      end
    end
  end
end
