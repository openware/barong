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
          optional :owner_uid, type: String, allow_blank: false, desc: 'owner uid'
          optional :owner_email, type: String, allow_blank: false, desc: 'owner email'
        end
        post '/list' do
          owner = User.find_by(uid: params[:owner_uid]) || User.find_by(email: params[:owner_email]) if params[:owner_uid] || params[:owner_email]
          service_accs = owner ? owner.service_accounts : ServiceAccount.all

          service_accs.tap { |q| present paginate(q), with: API::V2::Entities::ServiceAccounts }
          status 200
        end

        desc 'Create service_account' do
          @settings[:scope] = :write_service_accounts
          success API::V2::Entities::ServiceAccounts
        end
        params do
          requires :service_account_role, type: String, allow_blank: false, desc: 'service_account role'
          optional :owner_uid, type: String, desc: 'owner uid'
          optional :service_account_uid, type: String, desc: 'service_account uid'
          optional :service_account_email, type: String, desc: 'service_account email'
          optional :service_account_state, type: String, desc: 'service_account state'
          optional :service_account_level, type: Integer, desc: 'service_account level'
        end

        post '/create' do
          owner = User.find_by(uid: params[:owner_uid])

          s_params = {
                      email: params[:service_account_email],
                      uid: params[:service_account_uid],
                      role: params[:service_account_role],
                      state: params[:service_account_state],
                      level: params[:service_account_level],
                      user: owner
                    }.compact
          service_acc = ServiceAccount.new(s_params)
          error!(service_acc.errors.full_messages, 422) unless service_acc.save

          present service_acc, with: API::V2::Entities::ServiceAccounts
          status 201
        end

        desc 'Update service_account' do
          @settings[:scope] = :write_service_accounts
          success API::V2::Entities::ServiceAccounts
        end
        params do
          requires :uid, type: String, allow_blank: false, desc: 'service_account uid'
          optional :owner_uid, type: String, allow_blank: false, desc: 'service_account owner uid'
        end
        post '/update' do
          service_acc = ServiceAccount.find_by(uid: params[:uid])
          error!('Service account doesnt exist', 422) unless service_acc

          owner = User.find_by(uid: params[:owner_uid])
          s_params = { owner_id: owner&.id }.compact
          code_error!(service_acc.errors.details, 422) unless service_acc.update(s_params)

          present service_acc, with: API::V2::Entities::ServiceAccounts
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
