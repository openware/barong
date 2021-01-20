require 'sidekiq'

module Jobs
  class JobFinishWorker
    include Sidekiq::Worker

  end
end
