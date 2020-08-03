require 'sidekiq'

module KYC
  module Kycaid
    class ApplicantWorker
      include Sidekiq::Worker

      def perform(profile_id)
        profile = Profile.find(profile_id)
        params = {
          type: 'PERSON',
          first_name: profile.first_name,
          last_name: profile.last_name,
          dob: profile.dob,
          residence_country: profile.country,
          email: profile.user.email,
          phone: profile.user.phones&.last&.number
        }

        applicant = ::KYCAID::Applicant.create(params)

        # applicant error usually means unathorized
        # applicant errors is nil on correct request and contains a structure: (example)
        # type="validation", errors=[{"parameter"=>"residence_country", "message"=>"Country of residence is not valid"} 
        if applicant.error || applicant.errors
          Rails.logger.info("Error in applicant creation for: #{profile.user.uid}: #{applicant.error}")
          profile.update(applicant_id: applicant.applicant_id, state: 'rejected')
        elsif applicant.applicant_id
          profile.update(applicant_id: applicant.applicant_id, state: 'verified')
          Rails.logger.info("For user with uid: #{profile.user.uid} applied kycaid applicant_id: #{applicant.applicant_id}")
        end
      end
    end
  end
end
