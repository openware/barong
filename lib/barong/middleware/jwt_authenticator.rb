# frozen_string_literal: true

module Barong
  module Middleware
    # Authenticate a user by a bearer token
    class JWTAuthenticator < Grape::Middleware::Base
      def initialize(app, options)
        super(app, options)
        raise(Peatio::Auth::Error, 'Public key missing') unless options[:pubkey]

        @keypub = options[:pubkey]
      end

      def before
        return if request.path.include? 'swagger'

        raise(Peatio::Auth::Error, 'Header Authorization missing') \
          unless authorization_present?

        token = request.headers['Authorization']
        env[:current_payload] = authenticator.authenticate!(token)
      end

      private

      # JWT Authenticator instance from peatio-core
      #
      # @return [Peatio::Auth::JWTAuthenticator]
      def authenticator
        @authenticator ||=
          Peatio::Auth::JWTAuthenticator.new(@keypub)
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
