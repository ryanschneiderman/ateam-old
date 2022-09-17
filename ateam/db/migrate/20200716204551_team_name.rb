class TeamName < ActiveRecord::Migration[5.2]
  def change
  	remove_column :teams, :name 
  	add_column :seasons, :team_name, :string
  end
end
