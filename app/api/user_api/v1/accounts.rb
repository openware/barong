# frozen_string_literal: true

module UserApi
  module V1
    class Accounts < Grape::API
      desc 'Account related routes'
      resource :accounts do
        desc 'Return information about current resource owner',
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 401, message: 'Invalid bearer token' }
             ]
        get '/me' do
          current_account.as_json(only: %i[uid email level role state otp_enabled])
        end

        desc 'Change account password',
             security: [{ "BearerToken": [] }],
             failure: [
               { code: 400, message: 'Required params are missing' },
               { code: 401, message: 'Invalid password or bearer token' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :old_password, :new_password
        end

        put '/password' do
          account = current_account
          declared_params = declared(params)

          unless account.valid_password? declared_params[:old_password]
            return error!('Invalid password', 401)
          end

          account.password = declared_params[:new_password]
          return error!('Invalid password', 400) unless declared_params[:new_password]
          return error!(account.errors.full_messages.to_sentence) unless account.save
        end

        desc 'Creates new account',
             success: { code: 201, message: 'Creates new account' },
             failure: [
               { code: 400, message: 'Required params are missing' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :email, type: String, desc: 'Account Email', allow_blank: false
          requires :password, type: String, desc: 'Account Password', allow_blank: false
          optional :recaptcha_response, type: String, desc: 'Response from Recaptcha widget'
        end
        post do
          account = Account.new(params.slice('email', 'password'))
          verify_captcha_if_enabled!(account: account,
                                     response: params['recaptcha_response'])

          error!(account.errors.full_messages, 422) unless account.save
        end

        desc 'Confirms an account',
             success: { code: 201, message: 'Confirms an account' },
             failure: [
               { code: 400, message: 'Required params are missing' },
               { code: 422, message: 'Validation errors' }
             ]
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

        desc 'Send confirmations instructions',
             security: [{ "BearerToken": [] }]
        params do
          requires :email, type: String,
                           desc: 'Account email',
                           allow_blank: false
        end
        post '/send_confirmation_instructions' do
          account = Account.send_confirmation_instructions declared(params)
          if account.errors.any?
            error!(account.errors.full_messages.to_sentence, 422)
          end

          { message: 'Confirmation instructions was sent successfully' }
        end

        desc 'Send unlock instructions',
             security: [{ "BearerToken": [] }]
        params do
          requires :email, type: String,
                           desc: 'Account email',
                           allow_blank: false
        end

        post '/send_unlock_instructions' do
          account = Account.send_unlock_instructions declared(params)
          if account.errors.any?
            error!(account.errors.full_messages.to_sentence, 422)
          end

          { message: 'Unlock instructions was sent successfully' }
        end

        desc 'Unlocks an account',
             success: { code: 201, message: 'Unlocks an account' },
             failure: [
               { code: 400, message: 'Required params are missing' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :unlock_token, type: String,
                                  desc: 'Token from email',
                                  allow_blank: false
        end
        post '/unlock' do
          account = Account.unlock_access_by_token(params[:unlock_token])
          if account.errors.any?
            error!(account.errors.full_messages.to_sentence, 422)
          end
        end
      end
    end
  end
end
