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
  validates :type, :description, :state, :start_at,
            presence: true
  validates :state, inclusion: { in: STATES }
  validates :type, inclusion: { in: TYPES }
  validate :validate_date_range

  # Callbacks
  after_commit do
    if pending?
      enqueue_start_job
      enqueue_finish_job
    end
  end

  private

  def enqueue_start_job
    Jobs::JobStartWorker.perform_at(start_at, to_sgid(for: 'job_start')) if start_at.present?
  end

  def enqueue_finish_job
    Jobs::JobFinishWorker.perform_at(finish_at, to_sgid(for: 'job_finish')) if finish_at.present?
  end

  def validate_date_range
    errors.add(:start_at, :invalid, message: 'invalid date') if start_at.nil? || (start_at.present? && start_at < Time.now)
    errors.add(:finish_at, :invalid, message: 'invalid date') if finish_at.present? && finish_at < Time.now
    errors.add(:base, :invalid, message: 'invalid date range') if start_at.present? && finish_at.present? && start_at > finish_at

    return errors
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
#  finish_at   :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
