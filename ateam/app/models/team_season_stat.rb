class TeamSeasonStat < ApplicationRecord
	belongs_to :stat_list
	belongs_to :season
end
