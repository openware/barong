# frozen_string_literal: true

class UIDGenerator
  def self.generate(prefix = 'ID')
    loop do
      uid = "%s%s" % [prefix.upcase, SecureRandom.hex(5).upcase]
      return uid if User.where(uid: uid).empty? && ServiceAccount.where(uid: uid).empty?
    end
  end
end
