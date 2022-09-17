class Game < ApplicationRecord
	has_many :stats
	has_many :stat_granules
	belongs_to :opponent
	has_many :team_advanced_stats
	has_many :stat_totals
	has_many :advanced_stats
	belongs_to :schedule_event
	has_many :posts, :as => :post_type
	has_many :notifications, :as => :notif_type
	belongs_to :season
	has_many :opponent_granules
end
