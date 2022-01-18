class MakePermissionUnique < ActiveRecord::Migration[5.2]
  def up
    say_with_time 'Remove duplicate permissions' do
      Permission.group(:role, :action, :verb, :path).count.each do |keys, count|
        role, action, verb, path = keys
        Permission.where(role: role, action: action, verb: verb, path: path).minimum(:created_at)

        Permission.connection.execute %{
        delete from permissions where id in
          (select id from permissions where role='#{role}' and action='#{action}' and verb='#{verb}' and path='#{path}' order by created_at limit #{count-1})
        }
      end
    end
    add_index :permissions, [:role, :action, :verb, :path], unique: true, name: :permission_uniqueness
  end

  def down
    remove_index :permissions, [:role, :action, :verb, :path]
  end
end
