class CustomerIdUserId < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :customer_id, :integer
  	add_index :users, :customer_id
  end
end
