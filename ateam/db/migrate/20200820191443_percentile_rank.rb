class PercentileRank < ActiveRecord::Migration[5.2]
  def change
  	add_column :lineup_stats, :percentile_rank, :integer
  	add_column :lineup_adv_stats, :percentile_rank, :integer
  end
end
