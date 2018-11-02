# frozen_string_literal: true

module Barong
  module Middleware
    # Authenticate a user by a bearer token
    class JWTAuthenticator < Grape::Middleware::Base
      def before
        authenticate(request.headers['Authorization']) if authorization_present?
      end

      private

      # Exception-safe version of #authenticate!.
      #
      # @return [String, Member, NilClass]
      def authenticate(*args)
        authenticate!(*args)
      end

      # Decodes and verifies JWT.
      # Returns authentic member email or raises an exception.
      #
      # @param [string] Authorization header with a Bearer token to decode
      # @return [String, Member, NilClass]
      def authenticate!(token)
        env['_current_user'] = authenticator.authenticate!(token)
      end

      # JWT Authenticator instance from peatio-core
      #
      # @return [Peatio::Auth::JWTAuthenticator]
      def authenticator
        @authenticator ||=
          Peatio::Auth::JWTAuthenticator.new(Rails.configuration.x.key.public)
      end

      def authorization_present?
        request.headers.key?('Authorization')
      end

      # Request entity
      #
      # @return [Grape::Request]
      def request
        @request ||= Grape::Request.new(env)
      end
    end
  end
end
