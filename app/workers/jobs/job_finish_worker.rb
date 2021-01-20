require 'sidekiq'

module Jobs
  class JobStartWorker
    include Sidekiq::Worker

    def perform(sgid)
      job = GlobalID::Locator.locate_signed(sgid, for: 'job_finish')

      # Activate job that will change job status to active and enable restrictions
    end
  end
end
