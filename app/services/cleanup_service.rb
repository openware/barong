module CleanupService
  class << self
    def delete_unverified(updated_at_limit)
      User.where("state = 'pending' AND updated_at < ?", updated_at_limit.to_datetime).delete_all
      Phone.where("validated_at IS NULL AND updated_at < ?", updated_at_limit.to_datetime).delete_all
    end
  end
end
