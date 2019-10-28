# frozen_string_literal: true

module API::V2
  module Utils
    def remote_ip
      env['action_dispatch.remote_ip'].to_s
    end

    def code_error!(errors, code)
      final = errors.inject([]) do |result, (key, errs)|
        result.concat(
          errs.map { |e| e.values.first }
                .uniq
                .flatten
                .map { |e| [key, e].join('.') }
        )
      end
      error!({ errors: final }, code)
    end
  end
end
