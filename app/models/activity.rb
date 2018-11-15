class Activity < ApplicationRecord
  CATEGORIES = %w[session password otp].freeze
  RESULTS = %w[succeed failed].freeze

  belongs_to :user

  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :result,   presence: true, inclusion: { in: RESULTS }

private

  def readonly?
    !new_record?
  end
end
