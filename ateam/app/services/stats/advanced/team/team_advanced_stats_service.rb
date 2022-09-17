

class Stats::Advanced::Team::TeamAdvancedStatsService

	def initialize(params)
		@team_field_goals = params[:team_field_goals].to_f 
		@opp_field_goals =params[:opp_field_goals].to_f
		@team_field_goal_misses = params[:team_field_goal_misses].to_f
		@opp_field_goal_misses = params[:opp_field_goal_misses].to_f 
		@team_off_reb = params[:team_off_reb].to_f 
		@opp_off_reb = params[:opp_off_reb].to_f 
		@team_def_reb = params[:team_def_reb].to_f
		@opp_def_reb = params[:opp_def_reb].to_f
		@team_turnovers = params[:team_turnovers].to_f 
		@opp_turnovers = params[:opp_turnovers].to_f 
		@team_free_throw_makes = params[:team_free_throw_makes].to_f 
		@opp_free_throw_makes = params[:opp_free_throw_makes].to_f 
		@team_free_throw_misses = params[:team_free_throw_misses].to_f 
		@opp_free_throw_misses = params[:opp_free_throw_misses].to_f 
		@team_points = params[:team_points].to_f 
		@opp_points = params[:opp_points].to_f 
		@assists = params[:team_assists].to_f
		@game_id = params[:game_id]
		@team_id = params[:team_id]
		@game_length = params[:game_length]
		@team_minutes = params[:team_minutes]
		@season_minutes = params[:team_season_minutes]
		@team_three_point_makes = params[:team_three_point_makes]
		@team_three_point_misses = params[:team_three_point_misses]
		@opp_three_point_makes = params[:opp_three_point_makes]
		
		@team_three_point_att = @team_three_point_makes + @team_three_point_misses
		@team_field_goal_att = @team_field_goals + @team_field_goal_misses
		@opp_field_goal_att = @opp_field_goals + @opp_field_goal_misses
		@team_free_throw_att = @team_free_throw_makes + @team_free_throw_misses
		@opp_free_throw_att = @opp_free_throw_makes + @opp_free_throw_misses
		@season_id = params[:season_id]

		@create_hash = []

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
				assist_ratio()
			end
		end

		create_stats

		return {"offensive_efficiency" => @offensive_efficiency, "season_offensive_efficiency" => @new_off_eff,  "defensive_efficiency" => @defensive_efficiency, "season_defensive_efficiency" => @new_def_eff, "possessions" => @possessions, "opp_possessions" => @opp_possessions}

	end

	private

	def possessions()
		@possessions = Stats::Advanced::Team::PossessionsService.new({
			team_field_goal_att: @team_field_goal_att,
			team_free_throw_att: @team_free_throw_att,
			team_turnovers: @team_turnovers,
			team_off_reb: @team_off_reb
		}).call

		@create_hash.push({
			stat_list_id: 42,
			game_id: @game_id,
			value: @possessions,
			is_opponent: false,
			season_id: @season_id
		})


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

		@create_hash.push({
			stat_list_id: 42,
			game_id: @game_id,
			value: @opp_possessions,
			is_opponent: true,
			season_id: @season_id
		})

	end

	def off_efficiency()
		@offensive_efficiency = Stats::Advanced::Team::OffensiveEfficiencyService.new({
			possessions: @possessions,
			team_points: @team_points,
		}).call

		@create_hash.push({
			stat_list_id: 29,
			game_id: @game_id,
			value: @offensive_efficiency,
			is_opponent: false,
			season_id: @season_id
		})

		
	end

	def def_efficiency()
		@defensive_efficiency = Stats::Advanced::Team::DefensiveEfficiencyService.new({
			opp_possessions: @opp_possessions,
			opp_points: @opp_points
		}).call

		@create_hash.push({
			stat_list_id: 30,
			game_id: @game_id,
			value: @defensive_efficiency,
			is_opponent: false,
			season_id: @season_id
		})

		
	end

	def pace()
		@pace = Stats::Advanced::Team::PaceService.new({
			possessions: @possessions,
			opp_possessions: @opp_possessions,
			team_minutes: @team_minutes,
			minutes_per_game: @game_length
		}).call

		@create_hash.push({
			stat_list_id: 45,
			game_id: @game_id,
			value: @pace,
			is_opponent: false,
			season_id: @season_id
		})

	end

	def free_throw_att_rate
		free_throw_att_rate = Stats::Advanced::FreeThrowAttemptRateService.new({
			free_throw_att: @team_free_throw_att,
			field_goal_att: @team_field_goal_att,
		}).call

		@create_hash.push({
			stat_list_id: 21,
			game_id: @game_id,
			value: free_throw_att_rate,
			is_opponent: false,
			season_id: @season_id
		})

		
	end

	def three_point_rate()
		three_point_rate = Stats::Advanced::ThreePtAttemptRateService.new({
			three_point_att: @team_three_point_att,
			field_goal_att: @team_field_goal_att,
		}).call

		@create_hash.push({
			stat_list_id: 20,
			game_id: @game_id,
			value: three_point_rate,
			is_opponent: false,
			season_id: @season_id
		})

		
	end

	def effective_fg_pct ()
		eff_fg = Stats::Advanced::EffectiveFgPctService.new({
			field_goals: @team_field_goals,
			field_goal_att: @team_field_goal_att,
			three_point_fg: @team_three_point_makes,
		}).call

		@create_hash.push({
			stat_list_id: 18,
			game_id: @game_id,
			value: eff_fg,
			is_opponent: false,
			season_id: @season_id
		})

		
	end

	def opp_effective_fg_pct()
		eff_fg = Stats::Advanced::EffectiveFgPctService.new({
			field_goals: @opp_field_goals,
			field_goal_att: @opp_field_goal_att,
			three_point_fg: @opp_three_point_makes,
		}).call

		@create_hash.push({
			stat_list_id: 18,
			game_id: @game_id,
			value: eff_fg,
			is_opponent: true,
			season_id: @season_id
		})


		
	end

	def turnover_pct()
		turnover_pct = Stats::Advanced::Player::TurnoverPctService.new({
			turnovers: @team_turnovers,
			field_goal_att: @team_field_goal_att,
			free_throw_att: @team_free_throw_att,
		}).call

		@create_hash.push({
			stat_list_id: 37,
			game_id: @game_id,
			value: turnover_pct,
			is_opponent: false,
			season_id: @season_id
		})

		
	end

	def opp_turnover_pct()
		turnover_pct = Stats::Advanced::Player::TurnoverPctService.new({
			turnovers: @opp_turnovers,
			field_goal_att: @opp_field_goal_att,
			free_throw_att: @opp_free_throw_att,
		}).call

		@create_hash.push({
			stat_list_id: 37,
			game_id: @game_id,
			value: turnover_pct,
			is_opponent: true,
			season_id: @season_id
		})

		
	end

	def offensive_reb_pct()
		oreb = Stats::Advanced::Team::TeamOffensiveRebPctService.new({
			team_off_reb: @team_off_reb,
			opp_def_reb: @opp_def_reb,
		}).call

		@create_hash.push({
			stat_list_id: 32,
			game_id: @game_id,
			value: oreb,
			is_opponent: false,
			season_id: @season_id
		})

	end

	def defensive_reb_pct()
		dreb = Stats::Advanced::Team::TeamDefensiveRebPctService.new({
			opp_off_reb: @opp_off_reb,
			team_def_reb: @team_def_reb,
		}).call

		@create_hash.push({
			stat_list_id: 33,
			game_id: @game_id,
			value: dreb,
			is_opponent: false,
			season_id: @season_id
		})

	end

	def free_throw_rate()
		if @team_field_goal_att == 0
			free_throw_rate = 0.0
		else 
			free_throw_rate = 100 * (1000 * @team_free_throw_makes / @team_field_goal_att).round / 1000.0
		end

		@create_hash.push({
			stat_list_id: 46,
			game_id: @game_id,
			value: free_throw_rate,
			is_opponent: false,
			season_id: @season_id
		})

	end

	def opp_free_throw_rate()
		if @opp_field_goal_att == 0 
			free_throw_rate = 0.0
		else 
			free_throw_rate = 100 * (1000 * @opp_free_throw_makes / @opp_field_goal_att).round / 1000.0
		end

		@create_hash.push({
			stat_list_id: 46,
			game_id: @game_id,
			value: free_throw_rate,
			is_opponent: true,
			season_id: @season_id
		})
	end

	def assist_ratio
		ast_ratio = Stats::Advanced::Team::AssistRatioService.new({
			assists: @assists,
			possessions: @possessions
		}).call

		@create_hash.push({
			stat_list_id: 50,
			game_id: @game_id,
			value: ast_ratio,
			is_opponent: false,
			season_id: @season_id
		})
	end

	def create_stats
		TeamAdvancedStat.import @create_hash
	end
end
