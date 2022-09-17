class UserFrontPage < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :front_page, :boolean
  end
end
