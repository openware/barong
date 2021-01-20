# frozen_string_literal: true

class Job < ApplicationRecord
  
  # Validations

  # states (pending, active, disabled) - enum
  # Make sure start at in the past for the job activation

  # Helpers

  def enqueue_start_job
    # same as finish job
  end

  def enqueue_finish_job
    Jobs::JobFinishWorker.perform_at(finish_at, to_sgid(for: 'job_finish'))
  end
end
