class TeamUserId < ActiveRecord::Migration[5.2]
  def change
  	add_reference :teams, :user, index: true
  	add_column :teams, :paid, :boolean
  end
end
