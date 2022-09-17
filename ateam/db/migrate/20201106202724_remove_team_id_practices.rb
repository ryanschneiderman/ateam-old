class RemoveTeamIdPractices < ActiveRecord::Migration[5.2]
  def change
  	remove_reference :practices, :team, index: true
  end
end
