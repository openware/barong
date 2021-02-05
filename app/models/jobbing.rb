# frozen_string_literal: true

class Jobbing < ApplicationRecord
  belongs_to :job
  belongs_to :reference, polymorphic: true
end

# == Schema Information
# Schema version: 20210122032626
#
# Table name: jobbings
#
#  id             :bigint           not null, primary key
#  job_id         :bigint           not null
#  reference_type :string(255)      not null
#  reference_id   :bigint           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_jobbings_on_job_id                           (job_id)
#  index_jobbings_on_reference_type_and_reference_id  (reference_type,reference_id)
#
