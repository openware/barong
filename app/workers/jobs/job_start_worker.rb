require 'sidekiq'

module Jobs
  class JobStartWorker
    include Sidekiq::Worker

    def perform(sgid)
      Rails.logger.info "JobStartWorker Start #{self.jid}"

      # Get job object from GlobalID
      job = GlobalID::Locator.locate_signed(sgid, for: 'job_start')
      return if job.nil?
      
      # Get restriction object reference
      restriction = job.reference
      return if restriction.nil?      

      # Activate job that will change job status to active and enable restrictions
      if job.pending? && restriction.state == "disabled"
        restriction.update!(state: :enabled)
        job.active!

        # clear cached restrictions, so they will be freshly refetched on the next call to /auth
        Rails.cache.delete('restrictions')
      else
        Rails.logger.warn "Only pending job and disabled restriction can be set to active and enabled"
      end

      Rails.logger.info "JobStartWorker End"
    end
  end
end
