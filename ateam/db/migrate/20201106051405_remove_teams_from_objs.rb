class RemoveTeamsFromObjs < ActiveRecord::Migration[5.2]
  def change
  	remove_reference :members, :team, index: true
  	remove_reference :games, :team, index: true
  	remove_reference :team_stats, :team, index: true
  	remove_reference :stat_totals, :team, index: true
  	remove_reference :team_season_stats, :team, index: true
  	remove_reference :season_team_adv_stats, :team, index: true
  	remove_reference :lineups, :team, index: true
  	remove_column :lineups, :name
  end
end
