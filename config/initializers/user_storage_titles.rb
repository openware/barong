# frozen_string_literal: true

# whitelisted data storage titles definitions
class UserStorageTitles
  class << self
    def list
      @list ||= YAML.load_file(Barong::App.config.config)['user_storage_titles'] || []
    end
  end
end
