# frozen_string_literal: true

module Helper
  def to_readable(field)
    field.to_s.humanize.downcase
  end
end


RSpec.configure { |config| config.include Helper }
