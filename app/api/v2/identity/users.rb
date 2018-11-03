# frozen_string_literal: true

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
          # WIP : by default after creation 
          # we hardcode 'active' for user creation for now, since we dont have confirmation logic for now
          active_user_params =  params.slice('email', 'password').merge!(state: "active")
          user = User.new(active_user_params)
          verify_captcha!(user: user,
                          response: params['recaptcha_response'])

          error!(user.errors.full_messages, 422) unless user.save
        end

        # desc 'Confirms an account',
        # success: { code: 201, message: 'Confirms an account' },
        # failure: [
        #   { code: 400, message: 'Required params are missing' },
        #   { code: 422, message: 'Validation errors' }
        # ]
        # params do
        #   requires :confirmation_token, type: String,
        #                                 desc: 'Confirmation jwt token',
        #                                 allow_blank: false
        # end
        # post '/confirm' do
        #   WIP : confirmation logic
        # end

        # desc 'Unlocks an account',
        # success: { code: 201, message: 'Unlocks an account' },
        # failure: [
        #   { code: 400, message: 'Required params are missing' },
        #   { code: 422, message: 'Validation errors' }
        # ]
        # params do
        #   requires :unlock_token, type: String,
        #                           desc: 'Unlock jwt token',
        #                           allow_blank: false
        # end
        # post '/unlock' do
        #   WIP : unlock logic
        # end
      end
    end
  end
end
