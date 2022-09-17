
class Stats::GameModeCallbackService

	def initialize(params)
		@team_id = params[:team_id]
		@curr_season_id = params[:curr_season_id]
		@bpm_sums = [0, 0]
		@all_bpms = []
	end

	def call
		@players = Member.joins(:assignments).where(season_id: @curr_season_id, is_player: true)
		team_advanced
		update_advanced_player_stats
		adjust_bpm
		lineup_stats
		stat_rankings

	end


	private

	def team_advanced
		team_ratings = Stats::Advanced::Team::SeasonTeamAdvancedStatsService.new({
			team_id: @team_id,
			season_id: @curr_season_id
		}).call
		if team_ratings["offensive_efficiency"].present? && team_ratings["defensive_efficiency"].present?
			@team_rating = team_ratings["offensive_efficiency"] - team_ratings["defensive_efficiency"]
		end
	end

	def update_advanced_player_stats
		@players.each do |player|
			@bpms = Stats::Advanced::Player::SeasonAdvancedStatsService.new({
				member_id: player.id,
				team_id: @team_id,
				season_id: @curr_season_id
			}).call
			@minutes = player.season_minutes / 60.0
			@team_minutes = TeamSeasonStat.where(stat_list_id: 16, is_opponent: false, season_id: @curr_season_id).take.value / 60.0
			if(@bpms["obpm"].present?)
				@bpm_sums[0] += @bpms["obpm"] * (@minutes / (@team_minutes / 5))
				@bpm_sums[1] += @bpms["bpm"] * (@minutes / (@team_minutes / 5))
				@all_bpms.push(@bpms)
			end	

			Stats::SeasonShootingStatsService.new({
				member_id: player.id,
				season_id: @curr_season_id
			}).call
		end
	end

	def adjust_bpm
		adjust_bpm_hash = []
		if @team_rating.present? && @bpm_sums[1].present?
			bpm_team_adjustment = (@team_rating * 1.2 - @bpm_sums[1])/5
		end

		@all_bpms.each do |bpm|
			new_bpm = bpm["bpm"] + bpm_team_adjustment
			new_bpm = new_bpm * 100 
			new_bpm = new_bpm.round / 100.0


			#obpm_team_adjustment = (@team_rating * 1.2 - @bpm_sums[1])/5
			new_obpm = bpm["obpm"] + bpm_team_adjustment
			new_obpm = new_obpm * 100
			new_obpm = new_obpm.round / 100.0
			

			season_stat = SeasonAdvancedStat.where(stat_list_id: 41, member_id: bpm["member_id"], season_id: @curr_season_id).take
			if season_stat
				season_stat.value = bpm["bpm"]
				season_stat.save
			else
				adjust_bpm_hash.push({
					stat_list_id: 41,
					member_id: bpm["member_id"],
					value: bpm["bpm"],
					season_id: @curr_season_id
				})
			end


			season_stat = SeasonAdvancedStat.where(stat_list_id: 39, member_id: bpm["member_id"], season_id: @curr_season_id).take
			if season_stat
				season_stat.value = bpm["obpm"]
				season_stat.save
			else
				adjust_bpm_hash.push({
					stat_list_id: 39,
					member_id: bpm["member_id"],
					value: bpm["obpm"],
					season_id: @curr_season_id
				})
			end
		end

		if adjust_bpm_hash.length > 0
			SeasonAdvancedStat.import adjust_bpm_hash
		end

	end

	def stat_rankings
		Stats::StatRankingsService.new({
			team_id: @team_id,
			season_id: @curr_season_id
		}).call

		Stats::Lineups::LineupStatRankingService.new({
			team_id: @team_id,
			season_id: @curr_season_id
		}).call
	end

	def lineup_stats
		lineups = Lineup.where(season_id: @curr_season_id)
		lineups.each do |lineup|
			Stats::Lineups::CalcLineupAdvancedService.new({
				lineup_id: lineup.id,
				season_id: @curr_season_id,
				team_id: @team_id
			}).call

			Stats::Lineups::LineupShootingStatsService.new({
				lineup_id: lineup.id,
				season_id: @curr_season_id,
				team_id: @team_id
			}).call
		end
	end

	
end
