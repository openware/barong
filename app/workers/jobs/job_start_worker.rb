require 'sidekiq'

module Jobs
  class JobStartWorker
    include Sidekiq::Worker

    def perform(sgid)
      Rails.logger.info "JobStartWorker: Start"

      # Get job object from GlobalID
      job = GlobalID::Locator.locate_signed(sgid, for: 'job_start')
      return if job.nil?

      case job.type
      when "maintenance"
        Rails.logger.info "JobStartWorker: Enable maintenance"
        enable_maintenance(job)
      else
        Rails.logger.warn "JobStartWorker: Job type #{job.type} is not supported"
      end

      Rails.logger.info "JobStartWorker: End"
    end

    private
    
    def enable_maintenance(job)
      # Get all restrictions by job
      restrictions = job.restrictions
      return if restrictions.empty?      

      # Activate job that will change job status to active and enable restrictions
      if job.pending?
        restrictions.update_all(state: :enabled)
        job.active!

        # clear cached restrictions, so they will be freshly refetched on the next call to /auth
        Rails.cache.delete('restrictions')
      else
        Rails.logger.warn "JobStartWorker: Only pending job and disabled restriction can be set to active and enabled"
      end
    end
  end
end
