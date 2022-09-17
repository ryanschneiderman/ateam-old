class UpdateDeleteId < ActiveRecord::Migration[5.2]
  def change
  	change_column :plays, :delete_id, :string
  end
end
