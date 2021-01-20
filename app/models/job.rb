# frozen_string_literal: true

class Job < ApplicationRecord
  # Relationships
  belongs_to :reference, polymorphic: true

  # Enum
  enum state: { pending: 0, active: 1, disabled: 2 }
  enum job_type: { whitelist: 0, maintenance: 1, blacklist: 2, blocklogin: 3 }

  # Contants
  STATES = states.keys.freeze
  JOB_TYPES = job_types.keys.freeze

  # Validations
  validates :reference_id, :reference_type, 
            :job_type, :description, :state,
            :start_at, :finish_at,
            presence: true
  validates :state, inclusion: { in: STATES }
  validates :job_type, inclusion: { in: JOB_TYPES }
  validate :validate_date_range

  after_create do
    if pending?
      enqueue_start_job
      enqueue_finish_job
    end
  end

  private

  def enqueue_start_job
    Jobs::JobStartWorker.perform_at(start_at, to_sgid(for: 'job_start'))
  end

  def enqueue_finish_job
    Jobs::JobFinishWorker.perform_at(finish_at, to_sgid(for: 'job_finish'))
  end

  def validate_date_range
    return if finish_at > start_at

    return errors.add(:base, :invalid, message: 'invalid date range')
  end
end

# == Schema Information
# Schema version: 20210120100145
#
# Table name: jobs
#
#  id             :bigint           not null, primary key
#  reference_type :string(255)      not null
#  reference_id   :bigint           not null
#  job_type       :integer          not null
#  description    :text(65535)      not null
#  state          :integer          not null
#  start_at       :datetime         not null
#  finish_at      :datetime         not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_jobs_on_reference_type_and_reference_id  (reference_type,reference_id)
#
