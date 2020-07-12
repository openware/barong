require 'sidekiq'
module KYC
  module Kycaid
    class VerificationsWorker
      include Sidekiq::Worker

      def perform(params)
        params = params.symbolize_keys
        params.slice(:verification_id, :applicant_id, :verified, :verifications)

        user = Profile.find_by(applicant_id: params[:applicant_id]).user
        verification = ::KYCAID::Verification.fetch(params[:verification_id])

        return unless verification.status == 'completed'

        verification.verifications.each do |verificaton_name, verification_decision|
          if verification_decision.symbolize_keys[:verified]
            verificaton_name = 'document' if verificaton_name == 'facial'

            next unless user.labels.find_by_key(verificaton_name)
            user.labels.find_by_key(verificaton_name).update(key: verificaton_name, value: 'verified', scope: :private)
          else
            user.labels.find_by_key(verificaton_name).update(key: verificaton_name, value: 'rejected', scope: :private)
          end
        end
      end
    end
  end
end
