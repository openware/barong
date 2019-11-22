# frozen_string_literal: true

module Rack
  module Session
    # redis store configuration class to act as session_store (cache_store)
    class Redis
      def set_session(env, session_id, new_session, options)
        with_lock env, false do
          with do |c|
            new_options = if env['api_v2.session_lifetime']
                            x = ActionDispatch::Request::Session::Options.new \
                              options.instance_variable_get(:@by),
                              options.instance_variable_get(:@env),
                              options.instance_variable_get(:@delegate)
                            x[:expire_after] = env['api_v2.session_lifetime']
                            x
                          else
                            options
                          end
            c.set(session_id, new_session, new_options)
          end
          session_id
        end
      end
    end
  end
end
