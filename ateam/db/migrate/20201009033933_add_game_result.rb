class AddGameResult < ActiveRecord::Migration[5.2]
  def change
  	add_column :games, :result, :integer
  end
end
