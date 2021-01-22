# frozen_string_literal: true

class Job < ApplicationRecord
  # disable STI to allow "type" as field name in the table
  self.inheritance_column = :_type_disabled

  # Relationships
  has_many :jobbings
  has_many :restrictions, :through => :jobbings, :source => :reference,
           :source_type => 'Restriction'

  # Enum
  enum state: { pending: 0, active: 1, disabled: 2 }
  enum type: { maintenance: 0 }

  # Contants
  STATES = states.keys.freeze
  TYPES = types.keys.freeze

  # Validations
  validates :type, :description, :state,
            :start_at, :finish_at,
            presence: true
  validates :state, inclusion: { in: STATES }
  validates :type, inclusion: { in: TYPES }
  validate :validate_date_range

  # Callbacks
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
    return errors.add(:finish_at, :invalid, message: 'invalid date range') if start_at > finish_at
  end
end

# == Schema Information
# Schema version: 20210122032626
#
# Table name: jobs
#
#  id          :bigint           not null, primary key
#  type        :integer          not null
#  description :text(65535)      not null
#  state       :integer          not null
#  start_at    :datetime         not null
#  finish_at   :datetime         not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
