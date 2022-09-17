
class Stats::Lineups::CalcLineupAdvancedService

	def initialize(params)
		@lineup_id = params[:lineup_id]
		@team_id = params[:team_id]
		@season_id = params[:season_id]

		team_stats = TeamStat.joins(:stat_list).select("team_stats.*, stat_lists.*").where("team_stats.season_id" => @season_id).sort_by{|e| e.stat_list_id}

		team_stats.each do |ts|
			init_team_stat(ts)
		end

		@field_goal_att = @field_goals + @field_goal_misses
		@free_throw_att = @free_throw_makes + @free_throw_misses
		@three_point_att = @three_point_fg + @three_point_misses
		@opp_field_goal_att = @opp_field_goals + @opp_field_goal_misses
		@opp_free_throw_att = @opp_free_throw_makes + @opp_free_throw_misses
		@opp_three_point_att = @opp_three_point_fg + @opp_three_point_misses
		@season_create_hash =[]
		@update_hash = []

	end

	def call
		is_ortg = false
		is_drtg = false
		team_advanced_stats = TeamStat.joins(:stat_list).select("stat_lists.advanced as advanced, team_stats.*").where("stat_lists.advanced" => true, "team_stats.season_id" => @season_id).sort_by{|e| e.stat_list_id}
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

		create_stats
		update_stats

	end

	private 

	def init_team_stat(team_stat)
		case team_stat.stat_list_id
		when 1
			@field_goals = LineupStat.where(lineup_id: @lineup_id, is_opponent: false, stat_list_id: 1, season_id: @season_id).take.value
			@opp_field_goals = LineupStat.where(lineup_id: @lineup_id, is_opponent: true, stat_list_id: 1, season_id: @season_id).take.value
		when 2
			@field_goal_misses = LineupStat.where(lineup_id: @lineup_id, is_opponent: false, stat_list_id: 2, season_id: @season_id).take.value
			@opp_field_goal_misses = LineupStat.where(lineup_id: @lineup_id, is_opponent: true, stat_list_id: 2, season_id: @season_id).take.value
		when 3
			@assists = LineupStat.where(lineup_id: @lineup_id, is_opponent: false, stat_list_id: 3, season_id: @season_id).take.value
			@opp_assists = LineupStat.where(lineup_id: @lineup_id, is_opponent: true, stat_list_id: 3, season_id: @season_id).take.value
		when 4
			@off_reb = LineupStat.where(lineup_id: @lineup_id, is_opponent: false, stat_list_id: 4, season_id: @season_id).take.value
			@opp_off_reb = LineupStat.where(lineup_id: @lineup_id, is_opponent: true, stat_list_id: 4, season_id: @season_id).take.value
		when 5
			@def_reb = LineupStat.where(lineup_id: @lineup_id, is_opponent: false, stat_list_id: 5, season_id: @season_id).take.value
			@opp_def_reb = LineupStat.where(lineup_id: @lineup_id, is_opponent: true, stat_list_id: 5, season_id: @season_id).take.value
		when 7
			@turnovers = LineupStat.where(lineup_id: @lineup_id, is_opponent: false, stat_list_id: 7, season_id: @season_id).take.value
			@opp_turnovers = LineupStat.where(lineup_id: @lineup_id, is_opponent: true, stat_list_id: 7, season_id: @season_id).take.value
		when 11
			@three_point_fg = LineupStat.where(lineup_id: @lineup_id, is_opponent: false, stat_list_id: 11, season_id: @season_id).take.value
			@opp_three_point_fg = LineupStat.where(lineup_id: @lineup_id, is_opponent: true, stat_list_id: 11, season_id: @season_id).take.value
		when 12
			@three_point_misses = LineupStat.where(lineup_id: @lineup_id, is_opponent: false, stat_list_id: 12, season_id: @season_id).take.value
			@opp_three_point_misses = LineupStat.where(lineup_id: @lineup_id, is_opponent: true, stat_list_id: 12, season_id: @season_id).take.value
		when 13
			@free_throw_makes = LineupStat.where(lineup_id: @lineup_id, is_opponent: false, stat_list_id: 13, season_id: @season_id).take.value
			@opp_free_throw_makes = LineupStat.where(lineup_id: @lineup_id, is_opponent: true, stat_list_id: 13, season_id: @season_id).take.value
		when 14
			@free_throw_misses = LineupStat.where(lineup_id: @lineup_id, is_opponent: false, stat_list_id: 14, season_id: @season_id).take.value
			@opp_free_throw_misses = LineupStat.where(lineup_id: @lineup_id, is_opponent: true, stat_list_id: 14, season_id: @season_id).take.value
		when 15
			@points = LineupStat.where(lineup_id: @lineup_id, is_opponent: false, stat_list_id: 15, season_id: @season_id).take.value
			@opp_points = LineupStat.where(lineup_id: @lineup_id, is_opponent: true, stat_list_id: 15, season_id: @season_id).take.value
		end
	end


	def possessions()
		@poss = Stats::Advanced::Team::PossessionsService.new({
			team_field_goal_att:  @field_goal_att,
			team_free_throw_att:  @free_throw_att,
			team_turnovers:  @turnovers,
			team_off_reb: @off_reb
		}).call


		@season_poss = LineupAdvStat.where(stat_list_id: 42, lineup_id: @lineup_id, season_id: @season_id, is_opponent: false).take
		if @season_poss

			@season_poss.value = @poss
			@update_hash.push(@season_poss)
		else
			@season_create_hash.push({
				stat_list_id: 42,
				lineup_id: @lineup_id, 
				season_id: @season_id,
				value: @poss,
				is_opponent: false
			})
		end
		

		@opp_poss = Stats::Advanced::Team::PossessionsService.new({
			team_field_goal_att:  @opp_field_goal_att,
			team_free_throw_att:  @opp_free_throw_att,
			team_turnovers:  @opp_turnovers,
			team_off_reb: @opp_off_reb
		}).call


		@season_opp_poss = LineupAdvStat.where(stat_list_id: 42, lineup_id: @lineup_id, season_id: @season_id, is_opponent: true).take
		if @season_opp_poss

			@season_opp_poss.value = @opp_poss
			@update_hash.push @season_opp_poss
		else
			@season_create_hash.push({
				stat_list_id: 42,
				lineup_id: @lineup_id, 
				season_id: @season_id,
				value: @opp_poss,
				is_opponent: true
			})
		end
	end

	def offensive_rating()
		@off_rating = Stats::Advanced::Team::OffensiveEfficiencyService.new({
			possessions: @poss,
			team_points: @points
		}).call


		season_off_rtg = LineupAdvStat.where(stat_list_id: 29, lineup_id: @lineup_id, season_id: @season_id, is_opponent: false).take
		if season_off_rtg

			season_off_rtg.value = @off_rating
			@update_hash.push season_off_rtg
		else
			@season_create_hash.push({
				stat_list_id: 29,
				lineup_id: @lineup_id, 
				season_id: @season_id,
				value: @off_rating,
				is_opponent: false
			})
			@new_off_eff = @off_rating
		end
	
	end

	def defensive_rating()
		@def_rating = Stats::Advanced::Team::DefensiveEfficiencyService.new({
			opp_possessions: @opp_poss,
			opp_points: @opp_points
		}).call


		season_def_rtg = LineupAdvStat.where(stat_list_id: 30, lineup_id: @lineup_id, season_id: @season_id, is_opponent: false).take
		if season_def_rtg

			season_def_rtg.value = @def_rating
			@update_hash.push(season_def_rtg)
		else
			@season_create_hash.push({
				stat_list_id: 30,
				lineup_id: @lineup_id, 
				season_id: @season_id,
				value: @def_rating,
				is_opponent: false
			})
			@new_def_eff = @def_rating
		end
	end

	def net_rating()
		season_net_rtg = LineupAdvStat.where(stat_list_id: 25, lineup_id: @lineup_id, season_id: @season_id, is_opponent: false).take
		if season_net_rtg
			season_net_rtg.value = @off_rating - @def_rating
			@update_hash.push(season_net_rtg)
		else
			@season_create_hash.push({
				stat_list_id: 25,
				lineup_id: @lineup_id, 
				season_id: @season_id,
				value: @off_rating - @def_rating,
				is_opponent: false
			})
		end
	end

	def ast_ratio()
		@ast_ratio = Stats::Advanced::Team::AssistRatioService.new({
			possessions: @poss,
			assists: @assists
		}).call

		season_ast_ratio = LineupAdvStat.where(stat_list_id: 50, lineup_id: @lineup_id, season_id: @season_id, is_opponent: false).take
		if season_ast_ratio

			season_ast_ratio.value = @ast_ratio
			@update_hash.push(season_ast_ratio)
		else
			@season_create_hash.push({
				stat_list_id: 50,
				lineup_id: @lineup_id, 
				season_id: @season_id,
				value: @ast_ratio,
				is_opponent: false
			})
		end
	end

	def oreb_pct()
		@oreb_pct = Stats::Advanced::Team::TeamOffensiveRebPctService.new({
			team_off_reb: @off_reb,
			opp_def_reb: @opp_def_reb
		}).call

		season_off_reb = LineupAdvStat.where(stat_list_id: 32, lineup_id: @lineup_id, season_id: @season_id, is_opponent: false).take
		if season_off_reb

			season_off_reb.value = @oreb_pct
			@update_hash.push(season_off_reb)
		else
			@season_create_hash.push({
				stat_list_id: 32,
				lineup_id: @lineup_id, 
				season_id: @season_id,
				value: @oreb_pct,
				is_opponent: false
			})
		end

		@opp_oreb_pct = Stats::Advanced::Team::TeamOffensiveRebPctService.new({
			team_off_reb: @opp_off_reb,
			opp_def_reb: @def_reb
		}).call

		opp_season_off_reb = LineupAdvStat.where(stat_list_id: 32, lineup_id: @lineup_id, season_id: @season_id, is_opponent: true).take
		if opp_season_off_reb

			opp_season_off_reb.value = @opp_oreb_pct
			@update_hash.push(opp_season_off_reb)
		else
			@season_create_hash.push({
				stat_list_id: 32,
				lineup_id: @lineup_id, 
				season_id: @season_id,
				value: @opp_oreb_pct,
				is_opponent: true
			})
		end
	end

	def dreb_pct()
		@dreb_pct = Stats::Advanced::Team::TeamDefensiveRebPctService.new({
			team_def_reb: @def_reb,
			opp_off_reb: @opp_off_reb
		}).call

		season_def_reb = LineupAdvStat.where(stat_list_id: 33, lineup_id: @lineup_id, season_id: @season_id, is_opponent: false).take
		if season_def_reb

			season_def_reb.value = @dreb_pct
			@update_hash.push(season_def_reb)
		else
			@season_create_hash.push({
				stat_list_id: 33,
				lineup_id: @lineup_id, 
				season_id: @season_id,
				value: @dreb_pct,
				is_opponent: false
			})
		end

		@opp_dreb_pct = Stats::Advanced::Team::TeamDefensiveRebPctService.new({
			team_def_reb: @opp_def_reb,
			opp_off_reb: @off_reb
		}).call

		opp_season_def_reb = LineupAdvStat.where(stat_list_id: 33, lineup_id: @lineup_id, season_id: @season_id, is_opponent: true).take
		if opp_season_def_reb

			opp_season_def_reb.value = @opp_dreb_pct
			@update_hash.push(opp_season_def_reb)
		else
			@season_create_hash.push({
				stat_list_id: 33,
				lineup_id: @lineup_id, 
				season_id: @season_id,
				value: @opp_dreb_pct,
				is_opponent: true
			})
		end
	end

	def efg_pct()
		@efg_pct = Stats::Advanced::EffectiveFgPctService.new({
			field_goals: @field_goals,
			field_goal_att: @field_goal_att,
			three_point_fg: @three_point_fg
		}).call

		season_efg = LineupAdvStat.where(stat_list_id: 18, lineup_id: @lineup_id, season_id: @season_id, is_opponent: false).take
		if season_efg

			season_efg.value = @efg_pct
			@update_hash.push(season_efg)
		else
			@season_create_hash.push({
				stat_list_id: 18,
				lineup_id: @lineup_id, 
				season_id: @season_id,
				value: @efg_pct,
				is_opponent: false
			})
		end

		@opp_efg_pct = Stats::Advanced::EffectiveFgPctService.new({
			field_goals: @opp_field_goals,
			field_goal_att: @opp_field_goal_att,
			three_point_fg: @opp_three_point_fg
		}).call

		opp_season_efg = LineupAdvStat.where(stat_list_id: 18, lineup_id: @lineup_id, season_id: @season_id, is_opponent: true).take
		if opp_season_efg

			opp_season_efg.value = @opp_efg_pct
			@update_hash.push(opp_season_efg)
		else
			@season_create_hash.push({
				stat_list_id: 18,
				lineup_id: @lineup_id, 
				season_id: @season_id,
				value: @opp_efg_pct,
				is_opponent: true
			})
		end
	end

	def ts_pct()
		@ts_pct = Stats::Advanced::TrueShootingPctService.new({
			points: @points,
			field_goal_att: @field_goal_att,
			free_throw_att: @free_throw_att
		}).call

		season_ts = LineupAdvStat.where(stat_list_id: 19, lineup_id: @lineup_id, season_id: @season_id, is_opponent: false).take
		if season_ts
			season_ts.value = @ts_pct
			@update_hash.push(season_ts)
		else
			@season_create_hash.push({
				stat_list_id: 19,
				lineup_id: @lineup_id, 
				season_id: @season_id,
				value: @ts_pct,
				is_opponent: false
			})
		end

		@opp_ts_pct = Stats::Advanced::TrueShootingPctService.new({
			points: @opp_points,
			field_goal_att: @opp_field_goal_att,
			free_throw_att: @opp_free_throw_att
		}).call

		opp_season_ts = LineupAdvStat.where(stat_list_id: 19, lineup_id: @lineup_id, season_id: @season_id, is_opponent: true).take
		if opp_season_ts
			opp_season_ts.value = @opp_ts_pct
			@update_hash.push(opp_season_ts)
		else
			@season_create_hash.push({
				stat_list_id: 19,
				lineup_id: @lineup_id, 
				season_id: @season_id,
				value: @opp_ts_pct,
				is_opponent: true
			})
		end
	end

	def turnover_pct()
		@tov_pct = Stats::Advanced::Player::TurnoverPctService.new({
			turnovers: @turnovers,
			field_goal_att: @field_goal_att,
			free_throw_att: @free_throw_att
		}).call

		season_tov_pct = LineupAdvStat.where(stat_list_id: 37, lineup_id: @lineup_id, season_id: @season_id, is_opponent: false).take
		if season_tov_pct
			season_tov_pct.value = @tov_pct
			@update_hash.push(season_tov_pct)
		else
			@season_create_hash.push({
				stat_list_id: 37,
				lineup_id: @lineup_id, 
				season_id: @season_id,
				value: @tov_pct,
				is_opponent: false
			})
		end

		@opp_tov_pct = Stats::Advanced::Player::TurnoverPctService.new({
			turnovers: @opp_turnovers,
			field_goal_att: @opp_field_goal_att,
			free_throw_att: @opp_free_throw_att
		}).call

		opp_season_tov_pct = LineupAdvStat.where(stat_list_id: 37, lineup_id: @lineup_id, season_id: @season_id, is_opponent: true).take
		if opp_season_tov_pct
			opp_season_tov_pct.value = @opp_tov_pct
			@update_hash.push(opp_season_tov_pct)
		else
			@season_create_hash.push({
				stat_list_id: 37,
				lineup_id: @lineup_id, 
				season_id: @season_id,
				value: @opp_tov_pct,
				is_opponent: true
			})
		end
	end

	def three_pt_attempt_rate()
		@tpar = Stats::Advanced::ThreePtAttemptRateService.new({
			field_goal_att: @field_goal_att,
			three_point_att: @three_point_att
		}).call

		season_tpar = LineupAdvStat.where(stat_list_id: 20, lineup_id: @lineup_id, season_id: @season_id, is_opponent: false).take
		if season_tpar
			season_tpar.value = @tpar
			@update_hash.push(season_tpar)
		else
			@season_create_hash.push({
				stat_list_id: 20,
				lineup_id: @lineup_id, 
				season_id: @season_id,
				value: @tpar,
				is_opponent: false
			})
		end

		@opp_tpar = Stats::Advanced::ThreePtAttemptRateService.new({
			field_goal_att: @opp_field_goal_att,
			three_point_att: @opp_three_point_att
		}).call

		opp_season_tpar = LineupAdvStat.where(stat_list_id: 20, lineup_id: @lineup_id, season_id: @season_id, is_opponent: true).take
		if opp_season_tpar
			opp_season_tpar.value = @opp_tpar
			@update_hash.push(opp_season_tpar)
		else
			@season_create_hash.push({
				stat_list_id: 20,
				lineup_id: @lineup_id, 
				season_id: @season_id,
				value: @opp_tpar,
				is_opponent: true
			})
		end
	end

	def free_throw_att_rate()
		@ftar = Stats::Advanced::FreeThrowAttemptRateService.new({
			field_goal_att: @field_goal_att,
			free_throw_att: @free_throw_att
		}).call

		season_ftar = LineupAdvStat.where(stat_list_id: 21, lineup_id: @lineup_id, season_id: @season_id, is_opponent: false).take
		if season_ftar
			season_ftar.value = @ftar
			@update_hash.push(season_ftar)
		else
			@season_create_hash.push({
				stat_list_id: 21,
				lineup_id: @lineup_id, 
				season_id: @season_id,
				value: @ftar,
				is_opponent: false
			})
		end

		@opp_ftar = Stats::Advanced::FreeThrowAttemptRateService.new({
			field_goal_att: @opp_field_goal_att,
			free_throw_att: @opp_free_throw_att
		}).call

		opp_season_ftar = LineupAdvStat.where(stat_list_id: 21, lineup_id: @lineup_id, season_id: @season_id, is_opponent: true).take
		if opp_season_ftar
			opp_season_ftar.value = @opp_ftar
			@update_hash.push(opp_season_ftar)
		else
			@season_create_hash.push({
				stat_list_id: 21,
				lineup_id: @lineup_id, 
				season_id: @season_id,
				value: @opp_ftar,
				is_opponent: true
			})
		end
	end
	
	def create_stats()
		if @season_create_hash.length > 0
			LineupAdvStat.import @season_create_hash
		end
	end

	def update_stats
		if @update_hash.length > 0
			LineupAdvStat.import @update_hash, on_duplicate_key_update: {conflict_target: [:id], columns: [:value, :updated_at]}
		end
	end

end
