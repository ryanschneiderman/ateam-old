class RemovePasswordSeason < ActiveRecord::Migration[5.2]
  def change
  	remove_column :seasons, :password
  end
end
