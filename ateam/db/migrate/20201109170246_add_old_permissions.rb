class AddOldPermissions < ActiveRecord::Migration[5.2]
  def change
  	add_column :members, :permissions_backup, :jsonb
  end
end
