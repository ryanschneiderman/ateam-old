class PlayDeleteJob < ActiveRecord::Migration[5.2]
  def change
  	add_column :plays, :delete_id, :integer
  end
end
