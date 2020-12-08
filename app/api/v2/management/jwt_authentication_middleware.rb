# frozen_string_literal: true

require 'stringio'

module API::V2
  module Management
    class JWTAuthenticationMiddleware < Grape::Middleware::Base
      extend Memoist
      mattr_accessor :security_configuration

      def before
        return if request.path == '/api/v2/management/swagger'

        check_request_method!
        check_query_parameters!
        check_content_type!
        payload = check_jwt!(jwt)

        env['rack.input'] = StringIO.new(payload.fetch(:data, {}).to_json)
      end

    private

      def request
        Grape::Request.new(env)
      end
      memoize :request

      def jwt
        JSON.parse(request.body.read)
      rescue StandardError => e
        raise Exceptions::Authentication, \
              message:       'Couldn\'t parse JWT.',
              debug_message: e.inspect,
              status:        400
      end
      memoize :jwt

      def check_request_method!
        return if request.post? || request.put?

        raise Exceptions::Authentication, \
              message: 'Only POST and PUT verbs are allowed.',
              status:  405
      end

      def check_query_parameters!
        return if request.GET.empty?

        raise Exceptions::Authentication, \
              message: 'Query parameters are not allowed.',
              status:  400
      end

      def check_content_type!
        return if request.content_type == 'application/json'

        raise Exceptions::Authentication, \
              message: 'Only JSON body is accepted.',
              status:  400
      end

      def check_jwt!(jwt)
        begin
          scope    = security_configuration.fetch(:scopes).fetch(security_scope)
          keychain = security_configuration
                     .fetch(:keychain)
                     .slice(*scope.fetch(:permitted_signers))
                     .each_with_object({}) { |(k, v), memo| memo[k] = v.fetch(:value) }
          result   = JWT::Multisig.verify_jwt(jwt, keychain, security_configuration.fetch(:jwt, {}))
        rescue StandardError => e
          Rails.logger.error "ManagementAPI check_jwt error: #{e.inspect}"
          raise Exceptions::Authentication, \
                message:       'Failed to verify JWT.',
                debug_message: e.inspect,
                status:        401
        end

        unless (scope.fetch(:mandatory_signers) - result[:verified]).empty?
          raise Exceptions::Authentication, \
                message: 'Not enough signatures for the action.',
                status:  401
        end

        result[:payload]
      end

      def security_scope
        request.env['api.endpoint'].options.fetch(:route_options).fetch(:scope)
      end
    end
  end
end
