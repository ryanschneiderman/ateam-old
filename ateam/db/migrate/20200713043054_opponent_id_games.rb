class OpponentIdGames < ActiveRecord::Migration[5.2]
  def change
  	add_index :games, :opponent_id
  end
end
