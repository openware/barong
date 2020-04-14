# frozen_string_literal: true

module API::V2
  module Utils
    def remote_ip
      ip_string = env['action_dispatch.remote_ip'].to_s
      Rails.logger.debug "User login IP address: #{ip_string}"

      ip_string
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

    def codec
      @_codec ||= Barong::JWT.new(key: Barong::App.config.keystore.private_key)
    end

    def language
      params[:lang].to_s.empty? ? 'EN' : params[:lang].upcase
    end

    def parse_refid!
      error!({ errors: ['identity.user.invalid_referral_format'] }, 422) unless params[:refid].start_with?(Barong::App.config.uid_prefix.upcase)
      user = User.find_by_uid(params[:refid])
      error!({ errors: ['identity.user.referral_doesnt_exist'] }, 422) if user.nil?

      user.id
    end

    def publish_confirmation(user, language, domain)
      token = codec.encode(sub: 'confirmation', email: user.email, uid: user.uid)
      EventAPI.notify(
        'system.user.email.confirmation.token',
        record: {
          user: user.as_json_for_event_api,
          language: language,
          domain: domain,
          token: token
        }
      )
    end
  end
end
