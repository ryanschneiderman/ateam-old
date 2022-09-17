class TeamsSeasons < ActiveRecord::Migration[5.2]
  def change
  	remove_column :teams, :primary_color
  	remove_column :teams, :secondary_color
  	remove_column :teams, :num_periods
  	remove_column :teams, :period_length
  	remove_column :teams, :dirty_stats
  	add_column :seasons, :primary_color, :integer
  	add_column :seasons, :secondary_color, :integer
  	add_column :seasons, :num_periods, :integer
  	add_column :seasons, :period_length, :integer
  	add_column :seasons, :dirty_stats, :boolean
  end
end
