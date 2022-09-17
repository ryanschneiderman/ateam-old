class Member < ApplicationRecord
	belongs_to :user, optional: true
	has_many :stats
	has_many :stat_granules
	has_many :practice_stats
	has_many :practice_stat_granules
	has_many :posts
	has_many :season_stats
	has_and_belongs_to_many :lineups
	has_many :assignments  
	has_many :roles, through: :assignments  
	has_many :member_notifs
	has_many :notifications, through: :member_notifs
	has_many :comments
	has_many :play_views
	belongs_to :season
end
