class SeasonPassword < ActiveRecord::Migration[5.2]
  def change
  	add_column :seasons, :username, :string
  	add_column :seasons, :password, :string
  	remove_column :teams, :username
  	remove_column :teams, :password
  end
end
