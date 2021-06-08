class Setup < ActiveRecord::Migration[5.2]
  def up
    execute File.read Rails.root.join('db','bitzlato','structure.sql') if Rails.env.test? || Rails.env.development?
  end
end
