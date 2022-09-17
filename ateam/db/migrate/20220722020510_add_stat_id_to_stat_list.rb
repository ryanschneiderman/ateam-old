class AddStatIdToStatList < ActiveRecord::Migration[7.0]
  def change
    add_column :stat_lists, :stat_id, :integer
    add_index :stat_lists, :stat_id
  end
end
