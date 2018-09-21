require 'grape/middleware/error'

module CORS
  def rack_response(*args)
    if env.fetch('REQUEST_URI').match?(/\A\/api\/v1\//)
      args << {} if args.count < 3
      UserApi::V1::CORS.call(args[2], origin: env['HTTP_ORIGIN'])
    end
    super(*args)
  end
end

Grape::Middleware::Error.prepend CORS
