# frozen_string_literal: true

module UserApi
  module V1
    # Responsible for CRUD for api keys
    class APIKeys < Grape::API
      resource :api_keys do
        desc 'List all api keys for current account.'
        get do
          present current_account.api_keys, with: Entities::APIKey
        end

        desc 'Return a api key by uid'
        params do
          requires :uid, type: String
        end
        get ':uid' do
          api_key = current_account.api_keys.find_by!(uid: params[:uid])
          present api_key, with: Entities::APIKey
        end

        desc 'Create an api key'
        params do
          requires :public_key, type: String,
                                allow_blank: false
          optional :scopes, type: String,
                            allow_blank: false,
                            desc: 'comma separated scopes'
          optional :expires_in, type: String,
                                allow_blank: false,
                                desc: 'expires_in duration in seconds'
        end
        post do
          api_key = current_account.api_keys.create(declared(params))
          if api_key.errors.any?
            error!(api_key.errors.full_messages.to_sentence, 422)
          end

          present api_key, with: Entities::APIKey
        end

        desc 'Updates an api key'
        params do
          requires :uid, type: String
          optional :public_key, type: String,
                                allow_blank: false
          optional :scopes, type: String,
                            allow_blank: false,
                            desc: 'comma separated scopes'
          optional :expires_in, type: String,
                                allow_blank: false,
                                desc: 'expires_in duration in seconds'
        end
        patch ':uid' do
          api_key = current_account.api_keys.find_by!(uid: params[:uid])
          api_key.update(declared(params, include_missing: false))
          if api_key.errors.any?
            error!(api_key.errors.full_messages.to_sentence, 422)
          end

          present api_key, with: Entities::APIKey
        end

        desc 'Delete an api key'
        params do
          requires :uid, type: String
        end
        delete ':uid' do
          api_key = current_account.api_keys.find_by!(uid: params[:uid])
          api_key.destroy
          status 204
        end
      end
    end
  end
end
