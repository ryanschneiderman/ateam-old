class TeamStatSeason < ActiveRecord::Migration[5.2]
  def change
  	add_reference :team_stats, :season, index: true
  end
end
