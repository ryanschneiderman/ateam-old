class RemoveGameFromOpponents < ActiveRecord::Migration[5.2]
  def change
    remove_reference :opponents, :game, index: true
  end
end
