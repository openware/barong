# frozen_string_literal: true

require_dependency 'barong/jwt'

module API::V2
  module Identity
    class Users < Grape::API
      desc 'User related routes'
      resource :users do
        desc 'Creates new user',
        success: { code: 201, message: 'Creates new user' },
        failure: [
          { code: 400, message: 'Required params are missing' },
          { code: 422, message: 'Validation errors' }
        ]
        params do
          requires :email, type: String, desc: 'User Email', allow_blank: false
          requires :password, type: String, desc: 'User Password', allow_blank: false
          requires :recaptcha_response, type: String, desc: 'Response from Recaptcha widget'
        end
        post do
          user_params =  params.slice('email', 'password')
          user = User.new(user_params)
          verify_captcha!(user: user,
                          response: params['recaptcha_response'])

          error!(user.errors.full_messages, 422) unless user.save
        end

        namespace :email do
          desc 'Send confirmations instructions',
          success: { code: 201, message: 'Generated verification code' },
          failure: [
            { code: 400, message: 'Required params are missing' },
            { code: 422, message: 'Validation errors' }
          ]
          params do
            requires :email, type: String,
                        desc: 'Account email',
                        allow_blank: false
          end
          post '/generate_code' do
            current_user = User.find_by_email(params[:email])
            if current_user.nil? || current_user.active?
              error!('User doesn\'t exist or has already been activated', 422)
            end

            token = codec.encode(sub: 'confirmation', email: params[:email], uid: current_user.uid)
            EventAPI.notify(
              'system.user.email.confirmation.token',
              {user: current_user.as_json_for_event_api, token: token})

            status 201
          end

          desc 'Confirms an account',
          success: { code: 201, message: 'Confirms an account' },
          failure: [
            { code: 400, message: 'Required params are missing' },
            { code: 422, message: 'Validation errors' }
          ]
          params do
            requires :token, type: String,
                                     desc: 'Token from email',
                                     allow_blank: false
          end
          post '/confirm_code' do
            payload = codec.decode_and_verify(
              params[:token],
              pub_key: Barong::App.config.keystore.public_key,
              sub: 'confirmation'
            )
            current_user = User.find_by_email(payload[:email])

            if current_user.nil? || current_user.active?
              error!('User doesn\'t exist or has already been activated', 422)
            end

            current_user.after_confirmation
            EventAPI.notify('system.user.email.confirmed', current_user.as_json_for_event_api)

            status 201
          end
        end

        namespace :password do
          desc 'Send password reset instructions',
          success: { code: 201, message: 'Generated password reset code' },
          failure: [
            { code: 400, message: 'Required params are missing' },
            { code: 422, message: 'Validation errors' },
            { code: 404, message: 'User doesn\'t exist'}
          ]
          params do
            requires :email, type: String,
                        desc: 'Account email',
                        allow_blank: false
          end

          post '/generate_code' do
            current_user = User.find_by_email(params[:email])

            error!('User doesn\'t exist', 404) if current_user.nil?

            token = codec.encode(sub: 'reset', email: params[:email], uid: current_user.uid)

            activity_record(user: current_user.id, action: 'request password reset', result: 'succeed', topic: 'password')

            EventAPI.notify('system.user.password.reset.token', user: current_user.as_json_for_event_api, token: token)
            status 201
          end

          desc 'Sets new account password',
          success: { code: 201, message: 'Resets password' },
          failure: [
            { code: 400, message: 'Required params are empty' },
            { code: 404, message: 'Record is not found' },
            { code: 422, message: 'Validation errors' }
          ]
          params do
            requires :reset_password_token, type: String,
                                            desc: 'Token from email',
                                            allow_blank: false
            requires :password, type: String,
                                desc: 'User password',
                                allow_blank: false
            requires :confirm_password, type: String,
                                desc: 'User password',
                                allow_blank: false
          end
          post '/confirm_code' do
            unless params[:password] == params[:confirm_password]
              error!('Passwords don\'t match', 422)
            end

            payload = codec.decode_and_verify(
              params[:reset_password_token],
              pub_key: Barong::App.config.keystore.public_key, sub: 'reset'
            )
            current_user = User.find_by_email(payload[:email])

            unless current_user.update(password: params[:password])
              error_note = { reason: current_user.errors.full_messages.to_sentence }.to_json
              activity_record(user: current_user.id, action: 'password reset',
                              result: 'failed', topic: 'password', data: error_note)
              error!(current_user.errors.full_messages, 422)
            end

            activity_record(user: current_user.id, action: 'password reset', result: 'succeed', topic: 'password')

            EventAPI.notify('system.user.password.reset', current_user.as_json_for_event_api)
            status 201
          end
        end
      end
    end
  end
end
