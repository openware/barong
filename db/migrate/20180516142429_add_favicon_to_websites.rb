class AddFaviconToWebsites < ActiveRecord::Migration[5.1]
  def change
    add_column :websites, :favicon, :string, after: :logo
  end
end
