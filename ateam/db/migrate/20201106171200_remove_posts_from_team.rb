class RemovePostsFromTeam < ActiveRecord::Migration[5.2]
  def change
  	remove_reference :posts, :team, index: true
  	remove_reference :practice_stat_totals, :team, index: true
  	remove_reference :schedule_events, :seasons, index: true
  	add_reference :practices, :season, index: true
  	add_reference :schedule_events, :season, index: true
  end
end
