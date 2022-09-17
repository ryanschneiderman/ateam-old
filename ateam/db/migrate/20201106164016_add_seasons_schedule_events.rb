class AddSeasonsScheduleEvents < ActiveRecord::Migration[5.2]
  def change
  	add_reference :schedule_events, :seasons, index: true
  end
end
