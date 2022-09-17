

## TODO: HASH!!!!!

class Stats::Advanced::Team::SeasonTeamAdvancedStatsService

	def initialize(params)
		@team_id = params[:team_id]
		team = Team.find_by_id(@team_id)
		@season_id = params[:season_id]
		season = Season.find_by_id(@season_id)
		@minutes_per_game = season.num_periods * season.period_length

		team_stats = TeamStat.joins(:stat_list).select("team_stats.*, stat_lists.*").where("team_stats.season_id" => @season_id).sort_by{|e| e.stat_list_id}
		team_stats.each do |ts|
			init_team_stat(ts)
		end

		# @team_field_goals =  TeamSeasonStat.where(stat_list_id: 1, is_opponent: false, season_id: @season_id).take.value
		# @opp_field_goals = TeamSeasonStat.where(stat_list_id: 1, is_opponent: true, season_id: @season_id).take.value

		# @team_field_goal_misses =  TeamSeasonStat.where(stat_list_id: 2, is_opponent: false, season_id: @season_id).take.value
		# @opp_field_goal_misses =  TeamSeasonStat.where(stat_list_id: 2, is_opponent: true, season_id: @season_id).take.value
		# @team_off_reb =  TeamSeasonStat.where(stat_list_id: 4, is_opponent: false, season_id: @season_id).take.value
		# @opp_off_reb =  TeamSeasonStat.where(stat_list_id: 4, is_opponent: true, season_id: @season_id).take.value
		# @team_def_reb =  TeamSeasonStat.where(stat_list_id: 5, is_opponent: false, season_id: @season_id).take.value
		# @opp_def_reb =  TeamSeasonStat.where(stat_list_id: 5, is_opponent: true, season_id: @season_id).take.value
		# @team_turnovers = TeamSeasonStat.where(stat_list_id: 7, is_opponent: false, season_id: @season_id).take.value
		# @opp_turnovers =  TeamSeasonStat.where(stat_list_id: 7, is_opponent: true, season_id: @season_id).take.value
		# @team_free_throw_makes =  TeamSeasonStat.where(stat_list_id: 13, is_opponent: false, season_id: @season_id).take.value
		# @opp_free_throw_makes =  TeamSeasonStat.where(stat_list_id: 13, is_opponent: true, season_id: @season_id).take.value
		# @team_free_throw_misses =  TeamSeasonStat.where(stat_list_id: 14, is_opponent: false, season_id: @season_id).take.value
		# @opp_free_throw_misses =  TeamSeasonStat.where(stat_list_id: 14, is_opponent: true, season_id: @season_id).take.value
		# @team_points =  TeamSeasonStat.where(stat_list_id: 15, is_opponent: false, season_id: @season_id).take.value
		# @opp_points =  TeamSeasonStat.where(stat_list_id: 15, is_opponent: true, season_id: @season_id).take.value
		# @team_three_point_makes = TeamSeasonStat.where(stat_list_id: 11, is_opponent: false, season_id: @season_id).take.value
		# @team_three_point_misses = TeamSeasonStat.where(stat_list_id: 12, is_opponent: false, season_id: @season_id).take.value
		# @opp_three_point_makes = TeamSeasonStat.where(stat_list_id: 11, is_opponent: true, season_id: @season_id).take.value
		# @assists = TeamSeasonStat.where(stat_list_id: 3, is_opponent: false, season_id: @season_id).take.value

  #   	@team_minutes = TeamSeasonStat.where(stat_list_id: 16, is_opponent: false, season_id: @season_id).take.value

		
		@team_three_point_att = @team_three_point_makes + @team_three_point_misses
		@team_field_goal_att = @team_field_goals + @team_field_goal_misses
		@opp_field_goal_att = @opp_field_goals + @opp_field_goal_misses
		@team_free_throw_att = @team_free_throw_makes + @team_free_throw_misses
		@opp_free_throw_att = @opp_free_throw_makes + @opp_free_throw_misses

		@create_hash = []
		@update_hash = []
	end

	def call
		team_advanced_stats = TeamStat.joins(:stat_list).select("stat_lists.advanced as advanced, team_stats.*").where("stat_lists.advanced" => true, "team_stats.season_id" => @season_id).sort_by{|e| e.stat_list_id}
		if team_advanced_stats.any?{|a| a.stat_list_id == 42}
			possessions()
			opp_possessions()
		end
		team_advanced_stats.each do |stat|
			case stat.stat_list_id
			when 18
				effective_fg_pct()
				opp_effective_fg_pct()
			when 20
				three_point_rate()
			when 21
				free_throw_att_rate()
			when 29
				off_efficiency()
			when 30
				def_efficiency()
			when 32
				offensive_reb_pct()
			when 33
				defensive_reb_pct()
			when 37
				turnover_pct()
				opp_turnover_pct()
			when 45
				pace()
			when 46
				free_throw_rate()
				opp_free_throw_rate()
			when 50
				ast_ratio()
			end
		end

		create_stats
		update_stats

		return {"offensive_efficiency" => @offensive_efficiency, "season_offensive_efficiency" => @new_off_eff,  "defensive_efficiency" => @defensive_efficiency, "season_defensive_efficiency" => @new_def_eff, "possessions" => @possessions, "opp_possessions" => @opp_possessions}

	end

	private

	def init_team_stat(team_stat)
		case team_stat.stat_list_id
		when 1
			@team_field_goals = TeamSeasonStat.where(stat_list_id: 1, is_opponent: false, season_id: @season_id).take.value
			@opp_field_goals =TeamSeasonStat.where(stat_list_id: 1, is_opponent: true, season_id: @season_id).take.value
		when 2
			@team_field_goal_misses = TeamSeasonStat.where(stat_list_id: 2, is_opponent: false, season_id: @season_id).take.value
			@opp_field_goal_misses = TeamSeasonStat.where(stat_list_id: 2, is_opponent: true, season_id: @season_id).take.value
		when 3
			@team_assists = TeamSeasonStat.where(stat_list_id: 3, is_opponent: false, season_id: @season_id).take.value
			@opp_assists = TeamSeasonStat.where(stat_list_id: 3, is_opponent: true, season_id: @season_id).take.value
		when 4
			@team_off_reb = TeamSeasonStat.where(stat_list_id: 4, is_opponent: false, season_id: @season_id).take.value
			@opp_off_reb = TeamSeasonStat.where(stat_list_id: 4, is_opponent: true, season_id: @season_id).take.value
		when 5
			@team_def_reb = TeamSeasonStat.where(stat_list_id: 5, is_opponent: false, season_id: @season_id).take.value
			@opp_def_reb = TeamSeasonStat.where(stat_list_id: 5, is_opponent: true, season_id: @season_id).take.value
		when 6
			@team_steals = TeamSeasonStat.where(stat_list_id: 6, is_opponent: false, season_id: @season_id).take.value
			@opp_steals = TeamSeasonStat.where(stat_list_id: 6, is_opponent: true, season_id: @season_id).take.value
		when 7
			@team_turnovers = TeamSeasonStat.where(stat_list_id: 7, is_opponent: false, season_id: @season_id).take.value
			@opp_turnovers = TeamSeasonStat.where(stat_list_id: 7, is_opponent: true, season_id: @season_id).take.value
		when 8
			@team_blocks = TeamSeasonStat.where(stat_list_id: 8, is_opponent: false, season_id: @season_id).take.value
			@opp_blocks = TeamSeasonStat.where(stat_list_id: 8, is_opponent: true, season_id: @season_id).take.value
		when 11
			@team_three_point_makes = TeamSeasonStat.where(stat_list_id: 11, is_opponent: false, season_id: @season_id).take.value
			@opp_three_point_makes = TeamSeasonStat.where(stat_list_id: 11, is_opponent: true, season_id: @season_id).take.value
		when 12
			@team_three_point_misses = TeamSeasonStat.where(stat_list_id: 12, is_opponent: false, season_id: @season_id).take.value
			@opp_three_point_missse = TeamSeasonStat.where(stat_list_id: 12, is_opponent: true, season_id: @season_id).take.value
		when 13
			@team_free_throw_makes = TeamSeasonStat.where(stat_list_id: 13, is_opponent: false, season_id: @season_id).take.value
			@opp_free_throw_makes = TeamSeasonStat.where(stat_list_id: 13, is_opponent: true, season_id: @season_id).take.value
		when 14
			@team_free_throw_misses = TeamSeasonStat.where(stat_list_id: 14, is_opponent: false, season_id: @season_id).take.value
			@opp_free_throw_misses = TeamSeasonStat.where(stat_list_id: 14, is_opponent: true, season_id: @season_id).take.value
		when 15
			@team_points = TeamSeasonStat.where(stat_list_id: 15, is_opponent: false, season_id: @season_id).take.value
			@opp_points =  TeamSeasonStat.where(stat_list_id: 15, is_opponent: true, season_id: @season_id).take.value
		when 16
			@team_minutes =  TeamSeasonStat.where(stat_list_id: 16, is_opponent: false, season_id: @season_id).take.value / 60.0
			puts "@team minutes in init"
			puts @team_minutes
			@opp_minutes = @team_minutes
		when 17
			@team_fouls = TeamSeasonStat.where(stat_list_id: 17, is_opponent: false, season_id: @season_id).take.value
			@opp_fouls = TeamSeasonStat.where(stat_list_id: 17, is_opponent: true, season_id: @season_id).take.value
		end
	end

	def possessions()
		@possessions = Stats::Advanced::Team::PossessionsService.new({
			team_field_goal_att: @team_field_goal_att,
			team_free_throw_att: @team_free_throw_att,
			team_turnovers: @team_turnovers,
			team_off_reb: @team_off_reb
		}).call


		@season_poss = SeasonTeamAdvStat.where(stat_list_id: 42, is_opponent: false, season_id: @season_id).take
		if @season_poss

			@season_poss.value = @possessions
			@update_hash.push(@season_poss)

		else
			@create_hash.push({
				stat_list_id: 42,
				value: @possessions,
				is_opponent: false,
				season_id: @season_id
			})
		end
	end

	def opp_possessions()
		@opp_possessions = Stats::Advanced::Team::PossessionsService.new({
			team_field_goal_att: @opp_field_goal_att,
			team_free_throw_att: @opp_free_throw_att,
			team_turnovers: @opp_turnovers,
			team_off_reb: @opp_off_reb
		}).call

		puts "SEASON OPP POSS"
		puts @opp_possessions

		@season_opp_poss = SeasonTeamAdvStat.where(stat_list_id: 42, is_opponent: true, season_id: @season_id).take
		if @season_opp_poss

			@season_opp_poss.value = @opp_possessions
			@update_hash.push(@season_opp_poss)
		else
			@create_hash.push({
				stat_list_id: 42,
				value: @opp_possessions,
				is_opponent: true,
				season_id: @season_id
			})
		end
	end

	def off_efficiency()
		@offensive_efficiency = Stats::Advanced::Team::OffensiveEfficiencyService.new({
			possessions: @possessions,
			team_points: @team_points,
		}).call

		season_stat = SeasonTeamAdvStat.where(stat_list_id: 29, is_opponent: false, season_id: @season_id).take
		if season_stat

			season_stat.value = @offensive_efficiency
			@update_hash.push(season_stat)
		else
			@create_hash.push({
				stat_list_id: 29,
				value: @offensive_efficiency,
				is_opponent: false,
				season_id: @season_id
			})
			@new_off_eff = @offensive_efficiency
		end
	end

	def def_efficiency()
		@defensive_efficiency = Stats::Advanced::Team::DefensiveEfficiencyService.new({
			opp_possessions: @opp_possessions,
			opp_points: @opp_points
		}).call


		season_stat = SeasonTeamAdvStat.where(stat_list_id: 30, is_opponent: false, season_id: @season_id).take
		if season_stat
			season_stat.value = @defensive_efficiency
			@update_hash.push(season_stat)
		else
			@create_hash.push({
				stat_list_id: 30,
				value: @defensive_efficiency,
				is_opponent: false,
				season_id: @season_id
			})
			@new_def_eff = @defensive_efficiency
		end
	end

	def pace()
		@pace = Stats::Advanced::Team::PaceService.new({
			possessions: @possessions,
			opp_possessions: @opp_possessions,
			team_minutes: @team_minutes,
			minutes_per_game: @minutes_per_game
		}).call


		season_pace = SeasonTeamAdvStat.where(stat_list_id: 45, is_opponent: false, season_id: @season_id).take
		if season_pace
			season_pace.value = @pace
			@update_hash.push(season_pace)
		else
			@create_hash.push({
				stat_list_id: 45,
				value: @pace,
				is_opponent: false,
				season_id: @season_id
			})
		end
	end

	def free_throw_att_rate
		free_throw_att_rate = Stats::Advanced::FreeThrowAttemptRateService.new({
			free_throw_att: @team_free_throw_att,
			field_goal_att: @team_field_goal_att,
		}).call

		season_fta_rate = SeasonTeamAdvStat.where(stat_list_id: 21, is_opponent: false, season_id: @season_id).take
		if season_fta_rate

			season_fta_rate.value = free_throw_att_rate
			@update_hash.push(season_fta_rate)
		else
			@create_hash.push({
				stat_list_id: 21,
				value: free_throw_att_rate,
				is_opponent: false,
				season_id: @season_id
			})
		end
	end

	def three_point_rate()
		three_point_rate = Stats::Advanced::ThreePtAttemptRateService.new({
			three_point_att: @team_three_point_att,
			field_goal_att: @team_field_goal_att,
		}).call

		season_three_point_rate = SeasonTeamAdvStat.where(stat_list_id: 20, is_opponent: false, season_id: @season_id).take
		if season_three_point_rate

			season_three_point_rate.value = three_point_rate
			@update_hash.push(season_three_point_rate)
		else
			@create_hash.push({
				stat_list_id: 20,
				value: three_point_rate,
				is_opponent: false,
				season_id: @season_id
			})
		end
	end

	def effective_fg_pct ()
		eff_fg = Stats::Advanced::EffectiveFgPctService.new({
			field_goals: @team_field_goals,
			field_goal_att: @team_field_goal_att,
			three_point_fg: @team_three_point_makes,
		}).call

		season_efg = SeasonTeamAdvStat.where(stat_list_id: 18, is_opponent: false, season_id: @season_id).take
		if season_efg

			season_efg.value = eff_fg
			@update_hash.push(season_efg)
		else
			@create_hash.push({
				stat_list_id: 18,
				value: eff_fg,
				is_opponent: false,
				season_id: @season_id
			})
		end
	end

	def opp_effective_fg_pct()
		eff_fg = Stats::Advanced::EffectiveFgPctService.new({
			field_goals: @opp_field_goals,
			field_goal_att: @opp_field_goal_att,
			three_point_fg: @opp_three_point_makes,
		}).call


		season_efg = SeasonTeamAdvStat.where(stat_list_id: 18, is_opponent: true, season_id: @season_id).take
		if season_efg

			season_efg.value = eff_fg
			@update_hash.push(season_efg)
		else
			@create_hash.push({
				stat_list_id: 18,
				value: eff_fg,
				is_opponent: true,
				season_id: @season_id
			})
		end
	end

	def turnover_pct()
		turnover_pct = Stats::Advanced::Player::TurnoverPctService.new({
			turnovers: @team_turnovers,
			field_goal_att: @team_field_goal_att,
			free_throw_att: @team_free_throw_att,
		}).call


		season_tov = SeasonTeamAdvStat.where(stat_list_id: 37, is_opponent: false, season_id: @season_id).take
		if season_tov

			season_tov.value = turnover_pct
			@update_hash.push(season_tov)
		else
			@create_hash.push({
				stat_list_id: 37,
				value: turnover_pct,
				is_opponent: false,
				season_id: @season_id
			})
		end
	end

	def opp_turnover_pct()
		turnover_pct = Stats::Advanced::Player::TurnoverPctService.new({
			turnovers: @opp_turnovers,
			field_goal_att: @opp_field_goal_att,
			free_throw_att: @opp_free_throw_att,
		}).call


		season_tov = SeasonTeamAdvStat.where(stat_list_id: 37, is_opponent: true, season_id: @season_id).take
		if season_tov

			season_tov.value = turnover_pct
			@update_hash.push(season_tov)
		else
			@create_hash.push({
				stat_list_id: 37,
				value: turnover_pct,
				is_opponent: true,
				season_id: @season_id
			})
		end
	end

	def offensive_reb_pct()
		oreb = Stats::Advanced::Team::TeamOffensiveRebPctService.new({
			team_off_reb: @team_off_reb,
			opp_def_reb: @opp_def_reb,
		}).call

		season_off_reb = SeasonTeamAdvStat.where(stat_list_id: 32, is_opponent: false, season_id: @season_id).take
		if season_off_reb

			season_off_reb.value = oreb
			@update_hash.push(season_off_reb)
		else
			@create_hash.push({
				stat_list_id: 32,
				value: oreb,
				is_opponent: false,
				season_id: @season_id
			})
		end
	end

	def defensive_reb_pct()
		dreb = Stats::Advanced::Team::TeamDefensiveRebPctService.new({
			opp_off_reb: @opp_off_reb,
			team_def_reb: @team_def_reb,
		}).call

		season_def_reb = SeasonTeamAdvStat.where(stat_list_id: 33, is_opponent: false, season_id: @season_id).take
		if season_def_reb

			season_def_reb.value = dreb
			@update_hash.push(season_def_reb)
		else
			@create_hash.push({
				stat_list_id: 33,
				value: dreb,
				is_opponent: false,
				season_id: @season_id
			})
		end
	end

	def free_throw_rate()
		if @team_field_goal_att == 0
			free_throw_rate = 0.0
		else 
			free_throw_rate = 100 * (100 * @team_free_throw_makes / @team_field_goal_att).round / 100.0
		end

		@season_ftr = SeasonTeamAdvStat.where(stat_list_id: 46, is_opponent: false, season_id: @season_id).take
		if @season_ftr
			@season_ftr.value = free_throw_rate
			@update_hash.push(@season_ftr)
		else
			@create_hash.push({
				stat_list_id: 46,
				value: free_throw_rate,
				is_opponent: false,
				season_id: @season_id
			})
		end
	end

	def opp_free_throw_rate()
		if @opp_field_goal_att == 0 
			free_throw_rate = 0.0
		else 
			free_throw_rate = 100 * (100 * @opp_free_throw_makes / @opp_field_goal_att).round / 100.0
		end

		season_ftr = SeasonTeamAdvStat.where(stat_list_id: 46, is_opponent: true, season_id: @season_id).take
		if season_ftr
			season_ftr.value = free_throw_rate
			@update_hash.push(season_ftr)
		else
			@create_hash.push({
				stat_list_id: 46,
				value: free_throw_rate,
				is_opponent: true,
				season_id: @season_id
			})

		end
	end

	def ast_ratio
		ast_ratio = Stats::Advanced::Team::AssistRatioService.new({
			assists: @team_assists,
			possessions: @possessions
		}).call

		season_astr = SeasonTeamAdvStat.where(stat_list_id: 50, is_opponent: false, season_id: @season_id).take
		if season_astr
			season_astr.value = ast_ratio
			@update_hash.push(season_astr)
		else
			@create_hash.push({
				stat_list_id: 50,
				value: ast_ratio,
				is_opponent: false,
				season_id: @season_id
			})
		end
	end

	def create_stats
		if @create_hash.length > 0
			SeasonTeamAdvStat.import @create_hash
		end
	end

	def update_stats
		if @update_hash.length > 0
			SeasonTeamAdvStat.import @update_hash, on_duplicate_key_update: {conflict_target: [:id], columns: [:value, :updated_at]}
		end
	end
end
