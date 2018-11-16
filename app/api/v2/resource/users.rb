# frozen_string_literal: true

module API::V2
  module Resource
    class Users < Grape::API
      resource :users do
        desc 'Returns current user'
        get '/me' do
          current_user.attributes.except('password_digest')
        end

        desc 'Returns user activity'
        params do
          requires :topic, type: String,
                              allow_blank: false,
                              desc: 'Topic of user activity. Allowed: [all, password, session, otp]'
        end
        get '/activity/:topic' do
          data = current_user.activities
          data = data.where(topic: params[:topic]) if params[:topic] != 'all'
          error!('No activity recorded or wrong topic ') unless data.present?
        end
      end
    end
  end
end
