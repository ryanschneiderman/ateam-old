##
## TODO: NEED TO RECALCULATE SHOOTING STATS!!!!!
##
##
class Stats::RollbackGameService

	def initialize(params)
		@game_id = params[:game_id]
		@season_id = params[:season_id]
		@player_stats_ungrouped = Stat.where(game_id: @game_id, season_id: @season_id)
		@player_stats = []
		@player_stats_ungrouped.group_by(&:member_id).each do |member_id, stats| @player_stats.push({member_id: member_id, stats: stats}) end
		@team_stats = StatTotal.where(game_id: @game_id, is_opponent: false, season_id: @season_id)

		@lineup_stats_ungrouped = LineupGameStat.where(game_id: @game_id, is_opponent: false, season_id: @season_id)
		@lineup_stats = []
		@lineup_stats_ungrouped.group_by(&:lineup_id).each do |lineup_id, stats| @lineup_stats.push({lineup_id: lineup_id, stats: stats}) end

		@lineup_opponent_stats_ungrouped = LineupGameStat.where(game_id: @game_id, is_opponent: true, season_id: @season_id)
		@lineup_opponent_stats = []
		@lineup_opponent_stats_ungrouped.group_by(&:lineup_id).each do |lineup_id, stats| @lineup_opponent_stats.push({lineup_id: lineup_id, stats: stats}) end

		@opponent_stats = StatTotal.where(game_id: @game_id, is_opponent: true, season_id: @season_id)
		@stat_granules = StatGranule.where(game_id: @game_id, season_id: @season_id)
		@opponent_granules = OpponentGranule.where(game_id: @game_id, season_id: @season_id)
		@member_id = nil
		game = Game.find_by_id(@game_id)
		@num_games = Game.where(played: true, season_id: @season_id).count
		@truncate = false;
		if params[:submit] != true
			game.update(played: false)
			game.save
		else

			if @num_games == 1
				@truncate = true
			end
		end

		@team_season_hash = []
		@lineup_hash = []
		@player_hash = []
		

	end

	def call
		if @truncate 
			Stats::TruncateStatsService.new(season_id: @season_id).call
		else
			rollback_team_stats
			rollback_stat_granules
			rollback_player_stats
			rollback_lineup_stats
			update_team_season
			update_lineup_stats
			update_player_stats
		end
	end

	private

	## TODO: hash 
	def rollback_team_stats
		@team_stats.each do |team_stat|
			team_season_stat = TeamSeasonStat.where(stat_list_id: team_stat.stat_list_id, is_opponent: false, season_id: @season_id)
			team_season_stat = team_season_stat.take
			team_season_stat.value -= team_stat.value
			@team_season_hash.push(team_season_stat)
			if team_stat.stat_list_id == 16 
				@team_minutes = team_season_stat.value
			end
			team_stat.destroy
		end
		@opponent_stats.each do |opp_stat|
			opp_season_stat = TeamSeasonStat.where(stat_list_id: opp_stat.stat_list_id, is_opponent: true, season_id: @season_id)
			opp_season_stat = opp_season_stat.take

			opp_season_stat.value -= opp_stat.value
			@team_season_hash.push(opp_season_stat)

			opp_stat.destroy
		end
	end

	## TODO: hash
	def rollback_lineup_stats
		@lineup_stats.each do |lineup|
			@lineup_id = lineup[:lineup_id]
			@lineup = Lineup.find_by_id(@lineup_id)
			lineup[:stats].each do |stat|
				season_stat = LineupStat.where(lineup_id: @lineup_id, stat_list_id: stat.stat_list_id, season_id: @season_id, is_opponent: false).take
				if stat.stat_list_id == 16 
					@lineup.season_minutes -= stat.value
					@lineup.save
					@lineup_minutes = @lineup.season_minutes
				end
				season_stat.value -= stat.value
				@lineup_hash.push(season_stat)
				stat.destroy
			end
		end
		@lineup_opponent_stats.each do |lineup|
			@lineup_id = lineup[:lineup_id]
			@lineup = Lineup.find_by_id(@lineup_id)
			lineup[:stats].each do |stat|
				season_stat = LineupStat.where(lineup_id: @lineup_id, stat_list_id: stat.stat_list_id, season_id: @season_id, is_opponent: true).take
				season_stat.value -= stat.value
				@lineup_hash.push(season_stat)
				stat.destroy
			end
		end
	end

	def rollback_player_stats
		@player_stats.each do |player|
			@member_id = player[:member_id]
			@member = Member.find_by_id(@member_id)
			player[:stats].each do |player_stat|
				season_stat = SeasonStat.where(member_id: @member_id, stat_list_id: player_stat.stat_list_id, season_id: @season_id).take
				if player_stat.stat_list_id == 16 
					if player_stat.value > 0
						@member.games_played -= 1
					end
					@member.season_minutes -= player_stat.value
					@member.save
					@minutes = @member.season_minutes
					puts "PRINTING MINUTES DECREMENT"
					puts player_stat.value
				end
				puts "player stat"
				puts player_stat

				puts "member_id"
				puts @member_id

				puts "stat_list_id"
				puts player_stat.stat_list_id

				puts "season_stat"
				puts season_stat
				if season_stat.present?
					season_stat.value -= player_stat.value
					@player_hash.push(season_stat)
				end
				player_stat.destroy
			end
		end
	end




	def rollback_stat_granules
		@stat_granules.each do |stat_granule|
			stat_granule.destroy
		end
		@opponent_granules.each do |opp_granule|
			opp_granule.destroy
		end
	end

	def update_team_season
		if @team_season_hash.length > 0
			TeamSeasonStat.import @team_season_hash, on_duplicate_key_update: {conflict_target: [:id], columns: [:value, :updated_at]}
		end
	end

	def update_lineup_stats
		if @lineup_hash.length > 0
			LineupStat.import @lineup_hash, on_duplicate_key_update: {conflict_target: [:id], columns: [:value, :updated_at]}
		end
	end

	def update_player_stats
		if @player_hash.length > 0
			SeasonStat.import @player_hash, on_duplicate_key_update: {conflict_target: [:id], columns: [:value, :updated_at]}
		end
	end

	

end
