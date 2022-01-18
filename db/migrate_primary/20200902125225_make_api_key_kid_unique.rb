class MakeApiKeyKidUnique < ActiveRecord::Migration[5.2]
  class APIKey < ActiveRecord::Base
    self.table_name = :apikeys
  end

  def up
    duplicated_records = APIKey.select(:kid).group(:kid).having("count(*) > 1")
    duplicated_records.each do |api_key|
      APIKey.where(kid: api_key.kid).destroy_all
    end

    add_index :apikeys, :kid, unique: true unless index_exists?(:apikeys, :kid)
  end

  def down
    remove_index :apikeys, :kid if index_exists?(:apikeys, :kid)
  end
end
