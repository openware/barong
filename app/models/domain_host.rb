class DomainHost < ApplicationRecord
  DEFAULT_DOMAIN = 'default'

  validates :domain, presence: true
  validates :host, presence: true, uniqueness: true

  def self.domains
    pluck(:domain).uniq
  end
end
