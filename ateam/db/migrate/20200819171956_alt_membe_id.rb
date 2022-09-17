class AltMembeId < ActiveRecord::Migration[5.2]
  def change
  	add_column :members, :alt_id, :integer, index: true
  end
end
