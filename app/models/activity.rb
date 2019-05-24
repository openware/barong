class Activity < ApplicationRecord
  TOPICS = %w[session password otp account].freeze
  RESULTS = %w[succeed failed].freeze

  belongs_to :user

  validates :user_ip, presence: true, allow_blank: false
  validates :user_agent, presence: true, trusty_agent: true
  validates :topic, presence: true, inclusion: { in: TOPICS }
  validates :result, presence: true, inclusion: { in: RESULTS }

  # this method allows to use all the methods of ::Browser module (platofrm, modern?, version etc)
  def browser
    Browser.new(user_agent)
  end

private

  def readonly?
    !new_record?
  end
end
