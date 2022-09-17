
## TODO: MAKE SURE TO CHECK FOR TEAM STATS!!! I.E. ONLY CALCULATE FOR STATS USER WANTS TO KEEP

class Stats::Lineups::LineupAdvancedService
	def initialize(params)
		@field_goal_att = params[:field_goal_att]
		@free_throw_att = params[:free_throw_att]
		@turnovers = params[:turnovers]
		@off_reb = params[:off_reb]
		@def_reb = params[:def_reb]
		@field_goals = params[:field_goals]
		@points = params[:points]
		@three_point_fg = params[:three_point_fg]
		@assists = params[:assists]


		@opp_field_goal_att = params[:opp_field_goal_att]
		@opp_free_throw_att = params[:opp_free_throw_att]
		@opp_turnovers = params[:opp_turnovers]
		@opp_off_reb = params[:opp_off_reb]
		@opp_def_reb = params[:opp_def_reb]
		@opp_points = params[:opp_points]
		@lineup_id = params[:lineup_id]
		@team_id = params[:team_id]
		@game_id = params[:game_id]
		@season_id = params[:season_id]
		@create_hash = []
		@season_create_hash = []
	end

	def call()
		is_ortg = false
		is_drtg = false
		team_advanced_stats = TeamStat.joins(:stat_list).select("stat_lists.advanced as advanced, team_stats.*").where("stat_lists.advanced" => true, "team_stats.season_id" => @season_id).sort_by{|e| e.stat_list_id}
		team_advanced_stats.each do |stat|

		end
		if team_advanced_stats.any?{|a| a.stat_list_id == 42}
			possessions()
		end
		team_advanced_stats.each do |stat|
			case stat.stat_list_id
			when 18
				efg_pct()
			when 19
				ts_pct()
			when 29
				offensive_rating()
				is_ortg = true
			when 30
				defensive_rating()
				is_drtg = true
			when 32
				oreb_pct()
			when 33
				dreb_pct()
			when 50
				ast_ratio()
			when 37
				turnover_pct()
			when 20 
				three_pt_attempt_rate()
			when 21
				free_throw_att_rate()
			end
		end

		if is_ortg && is_drtg
			net_rating()
		end


		#PIE
	end

	private
	def possessions()
		@poss = Stats::Advanced::Team::PossessionsService.new({
			team_field_goal_att:  @field_goal_att,
			team_free_throw_att:  @free_throw_att,
			team_turnovers:  @turnovers,
			team_off_reb: @off_reb
		}).call
		@create_hash.push({
			stat_list_id: 42,
			lineup_id: @lineup_id, 
			season_id: @season_id,
			game_id: @game_id,
			value: @poss,
			is_opponent: false
		})

		@opp_poss = Stats::Advanced::Team::PossessionsService.new({
			team_field_goal_att:  @opp_field_goal_att,
			team_free_throw_att:  @opp_free_throw_att,
			team_turnovers:  @opp_turnovers,
			team_off_reb: @opp_off_reb
		}).call

		@create_hash.push({
			stat_list_id: 42,
			lineup_id: @lineup_id, 
			season_id: @season_id,
			game_id: @game_id,
			value: @opp_poss,
			is_opponent: true
		})
	end

	def offensive_rating()
		@off_rating = Stats::Advanced::Team::OffensiveEfficiencyService.new({
			possessions: @poss,
			team_points: @points
		}).call

		@create_hash.push({
			stat_list_id: 29,
			lineup_id: @lineup_id, 
			season_id: @season_id,
			game_id: @game_id,
			value: @off_rating,
			is_opponent: false
		})
	end

	def defensive_rating()
		@def_rating = Stats::Advanced::Team::DefensiveEfficiencyService.new({
			opp_possessions: @opp_poss,
			opp_points: @opp_points
		}).call

		@create_hash.push({
			stat_list_id: 30,
			lineup_id: @lineup_id, 
			season_id: @season_id,
			game_id: @game_id,
			value: @def_rating,
			is_opponent: false
		})

	end

	def net_rating()
		@net_rating = @off_rating - @def_rating 

		@create_hash.push({
			stat_list_id: 25,
			lineup_id: @lineup_id, 
			season_id: @season_id,
			game_id: @game_id,
			value: @net_rating,
			is_opponent: false
		})

	end

	def ast_ratio()
		@ast_ratio = Stats::Advanced::Team::AssistRatioService.new({
			possessions: @poss,
			assists: @assists
		}).call

		@create_hash.push({
			stat_list_id: 50,
			lineup_id: @lineup_id, 
			season_id: @season_id,
			game_id: @game_id,
			value: @ast_ratio,
			is_opponent: false
		})

	end

	def oreb_pct()
		@oreb_pct = Stats::Advanced::Team::TeamOffensiveRebPctService.new({
			team_off_reb: @off_reb,
			opp_def_reb: @opp_def_reb
		}).call

		@create_hash.push({
			stat_list_id: 32,
			lineup_id: @lineup_id, 
			season_id: @season_id,
			game_id: @game_id,
			value: @oreb_pct,
			is_opponent: false
		})

	end

	def dreb_pct()
		@dreb_pct = Stats::Advanced::Team::TeamDefensiveRebPctService.new({
			team_def_reb: @def_reb,
			opp_off_reb: @opp_off_reb
		}).call

		@create_hash.push({
			stat_list_id: 33,
			lineup_id: @lineup_id, 
			season_id: @season_id,
			game_id: @game_id,
			value: @dreb_pct,
			is_opponent: false
		})

	end

	def efg_pct()
		@efg_pct = Stats::Advanced::EffectiveFgPctService.new({
			field_goals: @field_goals,
			field_goal_att: @field_goal_att,
			three_point_fg: @three_point_fg
		}).call

		@create_hash.push({
			stat_list_id: 18,
			lineup_id: @lineup_id, 
			season_id: @season_id,
			game_id: @game_id,
			value: @efg_pct,
			is_opponent: false
		})

	end

	def ts_pct()
		@ts_pct = Stats::Advanced::TrueShootingPctService.new({
			points: @points,
			field_goal_att: @field_goal_att,
			free_throw_att: @free_throw_att
		}).call

		@create_hash.push({
			stat_list_id: 19,
			lineup_id: @lineup_id, 
			season_id: @season_id,
			game_id: @game_id,
			value: @ts_pct,
			is_opponent: false
		})

		@ts_pct = Stats::Advanced::TrueShootingPctService.new({
			points: @points,
			field_goal_att: @field_goal_att,
			free_throw_att: @free_throw_att
		}).call

		@create_hash.push({
			stat_list_id: 19,
			lineup_id: @lineup_id, 
			season_id: @season_id,
			game_id: @game_id,
			value: @ts_pct,
			is_opponent: false
		})

	end

	def turnover_pct()
		@tov_pct = Stats::Advanced::Player::TurnoverPctService.new({
			turnovers: @turnovers,
			field_goal_att: @field_goal_att,
			free_throw_att: @free_throw_att
		}).call

		@create_hash.push({
			stat_list_id: 37,
			lineup_id: @lineup_id, 
			season_id: @season_id,
			game_id: @game_id,
			value: @tov_pct,
			is_opponent: false
		})

		@opp_tov_pct = Stats::Advanced::Player::TurnoverPctService.new({
			turnovers: @opp_turnovers,
			field_goal_att: @opp_field_goal_att,
			free_throw_att: @opp_free_throw_att
		}).call

		@create_hash.push({
			stat_list_id: 37,
			lineup_id: @lineup_id, 
			season_id: @season_id,
			game_id: @game_id,
			value: @opp_tov_pct,
			is_opponent: true
		})
	end

	def three_pt_attempt_rate()
	end

	def free_throw_att_rate()
	end

	def create_stats()
		LineupGameAdvancedStat.import @create_hash
	end


end