class SeasonYearsFlag < ActiveRecord::Migration[5.2]
  def change
  	add_column :seasons, :multiple_years_flag, :boolean
  end
end
