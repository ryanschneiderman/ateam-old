class PlayerNumbers < ActiveRecord::Migration[5.2]
  def change
  	add_column :members, :number, :integer
  end
end
