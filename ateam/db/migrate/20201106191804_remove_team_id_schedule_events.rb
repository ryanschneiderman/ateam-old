class RemoveTeamIdScheduleEvents < ActiveRecord::Migration[5.2]
  def change
  	remove_reference :schedule_events, :team, index: true
  end
end
