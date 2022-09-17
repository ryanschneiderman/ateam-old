class StatListAbbr < ActiveRecord::Migration[5.2]
  def change
  	add_column :stat_lists, :abbr, :string
  end
end
