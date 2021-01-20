# frozen_string_literal: true

class Job < ApplicationRecord
  belongs_to :reference, polymorphic: true
end

# == Schema Information
# Schema version: 20210120084950
#
# Table name: jobs
#
#  id             :bigint           not null, primary key
#  type           :string(20)       default("maintenance"), not null
#  reason         :text(65535)
#  state          :string(20)       default("pending"), not null
#  start_at       :datetime
#  finish_at      :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  reference_type :string(255)      not null
#  reference_id   :bigint           not null
#
# Indexes
#
#  index_jobs_on_reference_type_and_reference_id  (reference_type,reference_id)
#
