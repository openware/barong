require 'sidekiq'

module Jobs
  class JobFinishWorker
    include Sidekiq::Worker

    def perform(sgid, finish_at)
      Rails.logger.info "JobFinishWorker: Start"

      # Get job object from GlobalID
      job = GlobalID::Locator.locate_signed(sgid, for: 'job_finish')
      return if job.nil?

      # Check for match time if job was rescheduled
      return if job.finish_at != finish_at 

      case job.type
      when "maintenance"
        Rails.logger.info "JobFinishWorker: Disable maintenance"
        disable_maintenance(job)
      else
        Rails.logger.warn "JobFinishWorker: Job type #{job.type} is not supported"
      end

      Rails.logger.info "JobFinishWorker: End"
    end

    private

    def disable_maintenance(job)
      # Get all restrictions by job
      restrictions = job.restrictions
      return if restrictions.empty?  

      # Deactivate job that will change job status to disabled and disabled restrictions
      if job.active?
        restriction.update_all(state: :disabled)
        job.disabled!

        # clear cached restrictions, so they will be freshly refetched on the next call to /auth
        Rails.cache.delete('restrictions')
      else
        Rails.logger.warn "JobFinishWorker: Only active job and enabled restriction can be set to disabled"
      end
    end
  end
end
