# frozen_string_literal: true

module API
  module V1
    class Accounts < Grape::API

      desc 'Account related routes'
      resource :accounts do
        desc 'Return information about current resource owner'
        get '/me' do
          current_account.as_json(only: %i[uid email level role state])
        end

        desc 'Change user\'s password'
        params do
          requires :old_password, :new_password
        end

        put '/password' do
          account = current_account
          declared_params = declared(params)

          unless account.valid_password? declared_params[:old_password]
            return error!('Invalid password.', 401)
          end

          account.password = declared_params[:new_password]
          return error!('Invalid password.', 400) unless declared_params[:new_password]
          return error!(account.errors.full_messages.to_sentence) unless account.save
        end

        desc 'Creates new account'
        params do
          requires :email, type: String, desc: 'Account Email', allow_blank: false
          requires :password, type: String, desc: 'Account Password', allow_blank: false
        end
        post do
          account = Account.create(declared(params))
          error!(account.errors.full_messages, 422) unless account.persisted?
        end

        desc 'Confirms new account'
        params do
          requires :confirmation_token, type: String,
                                        desc: 'Token from email',
                                        allow_blank: false
        end
        post '/confirm' do
          account = Account.confirm_by_token(params[:confirmation_token])
          if account.errors.any?
            error!(account.errors.full_messages.to_sentence, 422)
          end
        end
      end
    end
  end
end
