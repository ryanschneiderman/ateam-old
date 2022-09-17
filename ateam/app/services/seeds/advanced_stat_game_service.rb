class Seeds::AdvancedStatGameService
	def initialize(params)
		@team_id = params[:team_id]
		@season_id = params[:season_id]
		@games = Game.where(season_id: @season_id)
		@season = Season.find_by_id(@season_id)
	end

	def call
		@games.each do |game|
			team_field_goals =  StatTotal.where(game_id: game.id, stat_list_id: 1, is_opponent: false).take.value
			opp_field_goals =  StatTotal.where(game_id: game.id, stat_list_id: 1, is_opponent: true).take.value
			team_field_goal_misses =  StatTotal.where(game_id: game.id, stat_list_id: 2, is_opponent: false).take.value
			opp_field_goal_misses =  StatTotal.where(game_id: game.id, stat_list_id: 2, is_opponent: true).take.value
			team_off_reb =  StatTotal.where(game_id: game.id, stat_list_id: 4, is_opponent: false).take.value
			opp_off_reb =  StatTotal.where(game_id: game.id, stat_list_id: 4, is_opponent: true).take.value
			team_turnovers =  StatTotal.where(game_id: game.id, stat_list_id: 7, is_opponent: false).take.value
			opp_turnovers =  StatTotal.where(game_id: game.id, stat_list_id: 7, is_opponent: true).take.value
			team_free_throw_makes =  StatTotal.where(game_id: game.id, stat_list_id: 13, is_opponent: false).take.value
			opp_free_throw_makes =  StatTotal.where(game_id: game.id, stat_list_id: 13, is_opponent: true).take.value
			team_free_throw_misses =  StatTotal.where(game_id: game.id, stat_list_id: 14, is_opponent: false).take.value
			opp_free_throw_misses =  StatTotal.where(game_id: game.id, stat_list_id: 14, is_opponent: true).take.value
			team_points =  StatTotal.where(game_id: game.id, stat_list_id: 15, is_opponent: false).take.value
			opp_points =  StatTotal.where(game_id: game.id, stat_list_id: 15, is_opponent: true).take.value
			game_length =  @season.num_periods * @season.period_length,
			team_minutes =  StatTotal.where(game_id: game.id, stat_list_id: 16, is_opponent: false).take.value
			team_season_minutes =  TeamSeasonStat.where(season_id: @season_id, stat_list_id: 16, is_opponent: false).take.value
			team_three_point_makes =  StatTotal.where(game_id: game.id, stat_list_id: 11, is_opponent: false).take.value
			team_three_point_misses =  StatTotal.where(game_id: game.id, stat_list_id: 12, is_opponent: false).take.value
			opp_def_reb =  StatTotal.where(game_id: game.id, stat_list_id: 5, is_opponent: true).take.value
			team_def_reb =  StatTotal.where(game_id: game.id, stat_list_id: 5, is_opponent: false).take.value
			opp_three_point_makes =  StatTotal.where(game_id: game.id, stat_list_id: 11, is_opponent: true).take.value
			opp_three_point_misses =  StatTotal.where(game_id: game.id, stat_list_id: 12, is_opponent: true).take.value
			season_id =  @season_id,
			team_assists =  StatTotal.where(game_id: game.id, stat_list_id: 3, is_opponent: false).take.value
			opp_assists =  StatTotal.where(game_id: game.id, stat_list_id: 3, is_opponent: true).take.value
			team_steals =  StatTotal.where(game_id: game.id, stat_list_id: 6, is_opponent: false).take.value
			opp_steals =  StatTotal.where(game_id: game.id, stat_list_id: 6, is_opponent: true).take.value
			team_blocks =  StatTotal.where(game_id: game.id, stat_list_id: 8, is_opponent: false).take.value
			opp_blocks =  StatTotal.where(game_id: game.id, stat_list_id: 8, is_opponent: true).take.value
			team_fouls =  StatTotal.where(game_id: game.id, stat_list_id: 17, is_opponent: false).take.value
			opp_fouls =  StatTotal.where(game_id: game.id, stat_list_id: 17, is_opponent: true).take.value


			team_adv_stats = Stats::Advanced::Team::TeamAdvancedStatsService.new({
				team_field_goals: team_field_goals ,
				opp_field_goals: opp_field_goals ,
				team_field_goal_misses: team_field_goal_misses ,
				opp_field_goal_misses: opp_field_goal_misses ,
				team_off_reb: team_off_reb ,
				opp_off_reb: opp_off_reb ,
				team_turnovers: team_turnovers ,
				opp_turnovers: opp_turnovers ,
				team_free_throw_makes: team_free_throw_makes ,
				opp_free_throw_makes: opp_free_throw_makes ,
				team_free_throw_misses: team_free_throw_misses ,
				opp_free_throw_misses: opp_free_throw_misses ,
				team_points: team_points ,
				opp_points: opp_points ,
				game_id: game.id,
				team_id: @team_id,
				game_length: @season.num_periods * @season.period_length,
				team_minutes: team_minutes ,
				team_season_minutes: TeamSeasonStat.where(season_id: @season_id, stat_list_id: 16, is_opponent: false).take.value,
				team_three_point_makes: team_three_point_makes ,
				team_three_point_misses: team_three_point_misses ,
				opp_def_reb: opp_def_reb ,
				team_def_reb: team_def_reb ,
				opp_three_point_makes: opp_three_point_makes ,
				season_id: @season_id,
				team_assists: team_assists ,
			}).call

			@possessions = team_adv_stats["possessions"]
			@opp_possessions = team_adv_stats["opp_possessions"]

			@defensive_efficiency = team_adv_stats["defensive_efficiency"]
			@offensive_efficiency = team_adv_stats["offensive_efficiency"]

			if(@offensive_efficiency != nil && @defensive_efficiency != nil)
				@team_rating = @offensive_efficiency - @defensive_efficiency
			end

			player_stats = Stat.where(game_id: game.id, stat_list_id: 16)

			player_stats.group_by(&:member_id).each do |member_id, stats|
				bpms = Stats::Advanced::AdvancedStatsService.new({
					field_goals: Stat.where(game_id: game.id, stat_list_id: 1, member_id: member_id).take.value,
					team_field_goals: team_field_goals,
					opp_field_goals: opp_field_goals,
					field_goal_misses: Stat.where(game_id: game.id, stat_list_id: 2, member_id: member_id).take.value,
					team_field_goal_misses: team_field_goal_misses,
					opp_field_goal_misses: opp_field_goal_misses,
					assists: Stat.where(game_id: game.id, stat_list_id: 3, member_id: member_id).take.value,
					team_assists: team_assists,
					opp_assists: opp_assists,
					off_reb: Stat.where(game_id: game.id, stat_list_id: 4, member_id: member_id).take.value,
					team_off_reb: team_off_reb,
					opp_off_reb: opp_off_reb,
					def_reb: Stat.where(game_id: game.id, stat_list_id: 5, member_id: member_id).take.value,
					team_def_reb: team_def_reb,
					opp_def_reb: opp_def_reb,
					steals: Stat.where(game_id: game.id, stat_list_id: 6, member_id: member_id).take.value,
					team_steals: team_steals,
					opp_steals: opp_steals,
					turnovers: Stat.where(game_id: game.id, stat_list_id: 7, member_id: member_id).take.value,
					team_turnovers: team_turnovers,
					opp_turnovers: opp_turnovers,
					blocks: Stat.where(game_id: game.id, stat_list_id: 8, member_id: member_id).take.value,
					team_blocks: team_blocks,
					opp_blocks: opp_blocks,
					three_point_fg: Stat.where(game_id: game.id, stat_list_id: 11, member_id: member_id).take.value,
					team_three_point_fg: team_three_point_makes,
					opp_three_point_fg: opp_three_point_makes,
					three_point_miss: Stat.where(game_id: game.id, stat_list_id: 12, member_id: member_id).take.value,
					team_three_point_miss: team_three_point_misses,
					opp_three_point_miss: opp_three_point_misses,
					free_throw_makes: Stat.where(game_id: game.id, stat_list_id: 13, member_id: member_id).take.value,
					team_free_throw_makes: team_free_throw_makes,
					opp_free_throw_makes: opp_free_throw_makes,
					free_throw_misses: Stat.where(game_id: game.id, stat_list_id: 14, member_id: member_id).take.value,
					team_free_throw_misses: team_free_throw_misses,
					opp_free_throw_misses: opp_free_throw_misses,
					points: Stat.where(game_id: game.id, stat_list_id: 15, member_id: member_id).take.value,
					team_points: team_points,
					opp_points: opp_points,
					minutes: Stat.where(game_id: game.id, stat_list_id: 16, member_id: member_id).take.value,
					team_minutes: team_minutes,
					opp_minutes: team_minutes,
					fouls: Stat.where(game_id: game.id, stat_list_id: 17, member_id: member_id).take.value,
					team_fouls: team_fouls,
					opp_fouls: opp_fouls,
					possessions: @possessions,
					opp_possessions: @opp_possessions,
					member_id: member_id,
					game_id: game.id,
					team_id: @team_id,
					season_id: @season_id
				}).call
			end


			
		end
	end
end