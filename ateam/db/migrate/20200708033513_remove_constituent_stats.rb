class RemoveConstituentStats < ActiveRecord::Migration[5.2]
  def change
  	remove_column :advanced_stats, :constituent_stats
  	remove_column :season_advanced_stats, :constituent_stats
  	remove_column :team_advanced_stats, :constituent_stats
  	remove_column :lineup_game_advanced_stats, :constituent_stats
  	remove_column :lineup_adv_stats, :constituent_stats
  	remove_column :season_team_adv_stats, :constituent_stats
  end
end
