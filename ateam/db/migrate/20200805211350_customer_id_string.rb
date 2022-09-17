class CustomerIdString < ActiveRecord::Migration[5.2]
  def change
  	change_column :users, :customer_id, :string
  end
end
