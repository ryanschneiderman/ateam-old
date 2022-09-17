class Lineup < ApplicationRecord
	has_and_belongs_to_many :members
	belongs_to :season
	has_many :lineup_stats
	has_many :lineup_adv_stats
end
