class ChangeApiKeyStructure < ActiveRecord::Migration[5.2]
  def change
    change_table :api_keys do |t|
      t.rename  :public_key, :kid
      t.string  :algorithm, null: false, default: 'SHA256', after: :kid
      t.remove  :expires_in
    end
  end
end
