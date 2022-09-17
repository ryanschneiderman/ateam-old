class DirtyStats < ActiveRecord::Migration[5.2]
  def change
  	add_column :teams, :dirty_stats, :boolean
  end
end
