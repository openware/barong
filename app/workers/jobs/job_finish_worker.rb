require 'sidekiq'

module Jobs
  class JobFinishWorker
    include Sidekiq::Worker

    def perform(sgid)
      Rails.logger.info "JobFinishWorker Start"

      # Get job object from GlobalID
      job = GlobalID::Locator.locate_signed(sgid, for: 'job_finish')
      return if job.nil?

      # Get restriction object reference
      restriction = job.reference
      return if restriction.nil?  

      # Deactivate job that will change job status to disabled and disabled restrictions
      if job.active? && restriction.state == "enabled"
        restriction.update!(state: :disabled)
        job.disabled!

        # clear cached restrictions, so they will be freshly refetched on the next call to /auth
        Rails.cache.delete('restrictions')
      else
        Rails.logger.warn "Only active job and enabled restriction can be set to disabled"
      end

      Rails.logger.info "JobFinishWorker End"
    end
  end
end
