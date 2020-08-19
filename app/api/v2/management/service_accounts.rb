# frozen_string_literal: true

module API::V2
  module Management
    # ServiceAccounts server-to-server API
    class ServiceAccounts < Grape::API
      helpers ::API::V2::NamedParams

      desc 'ServiceAccounts related routes'
      resource :service_accounts do

        desc 'Get specific service_account information' do
          @settings[:scope] = :read_service_accounts
          success API::V2::Entities::ServiceAccounts
        end
        params do
          optional :uid, type: String, allow_blank: false, desc: 'service_account uid'
          optional :email, type: String, allow_blank: false, desc: 'service_account email'
          exactly_one_of :uid, :email
        end
        post '/get' do
          declared_params = declared(params, include_missing: false)

          service_acc = ServiceAccount.find_by!(declared_params)
          error!('Service account doesnt exist', 422) unless service_acc

          present service_acc, with: API::V2::Entities::ServiceAccounts
          status 200
        end

        desc 'Get service_accounts as a paginated collection' do
          @settings[:scope] = :read_service_accounts
          success API::V2::Entities::ServiceAccounts
        end
        params do
          use :pagination_filters
          optional :provider_uid, type: String, allow_blank: false, desc: 'provider uid'
          optional :provider_email, type: String, allow_blank: false, desc: 'provider email'
        end
        post '/list' do
          provider = User.find_by(uid: params[:provider_uid]) || User.find_by(email: params[:provider_email]) if params[:provider_uid] || params[:provider_email]
          service_accs = provider ? provider.service_accounts : ServiceAccount.all

          service_accs.tap { |q| present paginate(q), with: API::V2::Entities::ServiceAccounts }
          status 200
        end

        desc 'Create service_account' do
          @settings[:scope] = :write_service_accounts
          success API::V2::Entities::ServiceAccounts
        end
        params do
          optional :service_account_uid, type: String, allow_blank: false, desc: 'service_account uid'
          requires :provider_uid, type: String, allow_blank: false, desc: 'provider uid'
          optional :service_account_email, type: String, allow_blank: false, desc: 'service_account email'
        end
        post '/create' do
          provider = User.find_by(uid: params[:provider_uid])
          error!('Provider doesnt exist', 422) unless provider

          s_params = { email: params[:service_account_email], uid: params[:service_account_uid] }.compact
          service_acc = ServiceAccount.new(s_params.merge(user: provider))
          error!(service_acc.errors.full_messages, 422) unless service_acc.save

          present service_acc, with: API::V2::Entities::ServiceAccounts
          status 201
        end

        desc 'Delete specific service_account' do
          @settings[:scope] = :write_service_accounts
          success API::V2::Entities::ServiceAccounts
        end
        params do
          requires :uid, type: String, allow_blank: false, desc: 'service_account uid'
        end
        post '/delete' do
          declared_params = declared(params, include_missing: false)

          service_acc = ServiceAccount.find_by!(declared_params)
          error!('Service account doesnt exist', 422) unless service_acc

          unless service_acc.update(state: 'disabled')
            code_error!(service_acc.errors.details, 422)
          end

          present service_acc, with: API::V2::Entities::ServiceAccounts
          status 200
        end
      end
    end
  end
end
