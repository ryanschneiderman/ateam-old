

class Stats::Lineups::LineupAdvancedStatsService

	def initialize(params)
		@field_goals = params[:field_goals].to_f
		@team_field_goals = params[:team_field_goals].to_f 
		@opp_field_goals =params[:opp_field_goals].to_f
		@field_goal_misses =params[:field_goal_misses].to_f
		@team_field_goal_misses = params[:team_field_goal_misses].to_f
		@opp_field_goal_misses = params[:opp_field_goal_misses].to_f 
		@assists = params[:assists].to_f 
		@team_assists = params[:team_assists].to_f
		@opp_assists = params[:opp_assists].to_f 
		@off_reb = params[:off_reb].to_f 
		@team_off_reb = params[:team_off_reb].to_f 
		@opp_off_reb = params[:opp_off_reb].to_f 
		@def_reb = params[:def_reb].to_f 
		@team_def_reb = params[:team_def_reb].to_f 
		@opp_def_reb = params[:opp_def_reb].to_f 
		@steals = params[:steals].to_f
		@team_steals = params[:team_steals].to_f 
		@opp_steals = params[:opp_steals].to_f 
		@turnovers = params[:turnovers].to_f 
		@team_turnovers = params[:team_turnovers].to_f 
		@opp_turnovers = params[:opp_turnovers].to_f 
		@blocks = params[:blocks].to_f 
		@team_blocks = params[:team_blocks].to_f 
		@opp_blocks = params[:opp_blocks].to_f 
		@three_point_fg = params[:three_point_fg].to_f 
		@team_three_point_fg = params[:team_three_point_fg].to_f 
		@opp_three_point_fg = params[:opp_three_point_fg].to_f 
		@three_point_miss = params[:three_point_miss].to_f 
		@team_three_point_miss = params[:team_three_point_miss].to_f 
		@opp_three_point_miss = params[:opp_three_point_miss].to_f 
		@free_throw_makes = params[:free_throw_makes].to_f 
		@team_free_throw_makes = params[:team_free_throw_makes].to_f 
		@opp_free_throw_makes = params[:opp_free_throw_makes].to_f 
		@free_throw_misses = params[:free_throw_misses].to_f 
		@team_free_throw_misses = params[:team_free_throw_misses].to_f 
		@opp_free_throw_misses = params[:opp_free_throw_misses].to_f 
		@points = params[:points].to_f 
		@team_points = params[:team_points].to_f 
		@opp_points = params[:opp_points].to_f 
		@minutes = params[:minutes].to_f 
		@team_minutes = params[:team_minutes].to_f

		@opp_minutes =  params[:team_minutes].to_f 
		puts "@team_minutes in lineup"
		puts @team_minutes
		@fouls = params[:fouls].to_f 
		@team_fouls = params[:team_fouls].to_f 
		@opp_fouls = params[:opp_fouls].to_f 


		@lineup_id = params[:lineup_id]
		@game_id = params[:game_id]
		@team_id = params[:team_id]


		

		@total_reb = @off_reb + @def_reb
		@team_total_reb = @team_off_reb + @team_def_reb
		@opp_total_reb = @opp_def_reb + @team_off_reb

		@field_goal_att = @field_goals + @field_goal_misses
		@team_field_goal_att = @team_field_goals + @team_field_goal_misses
		@opp_field_goal_att = @opp_field_goals + @opp_field_goal_misses
		@free_throw_att = @free_throw_makes + @free_throw_misses
		@team_free_throw_att = @team_free_throw_makes + @team_free_throw_misses
		@opp_free_throw_att = @opp_free_throw_makes + @opp_free_throw_misses
		@three_point_att = @three_point_fg + @three_point_miss
		@team_three_point_att = @team_three_point_fg + @team_three_point_miss
		@opp_three_point_att = @opp_three_point_fg + @opp_three_point_miss

		@possessions = Advanced::PossessionsService.new({
			team_field_goal_att: @team_field_goal_att,
			team_free_throw_att: @team_free_throw_att,
			team_turnovers: @team_turnovers,
			team_off_reb: @team_off_reb
		}).call

		@opp_possessions = Advanced::PossessionsService.new({
			team_field_goal_att: @opp_field_goal_att,
			team_free_throw_att: @opp_free_throw_att,
			team_turnovers: @opp_turnovers,
			team_off_reb: @opp_off_reb
		}).call

	end

	def call
		advanced_stats = TeamStat.joins(:stat_list).select("stat_lists.advanced as advanced, team_stats.*").where("stat_lists.advanced" => true, "team_stats.team_id" => @team_id).sort_by{|e| e.stat_list_id}

		advanced_stats.each do |stat|
			case stat.stat_list_id
			when 18 
				effective_fg_pct()
			when 19
				true_shooting()
			when 20 
				three_pt_attempt_rate()
			when 21
				free_throw_att_rate()
			when 32
				offensive_rb_pct()
			when 33
				defensive_reb_pct()
			when 34
				total_reb_pct()
			when 37
				turnover_pct()
			end		
		end

		## return box plus minus values to adjust later
		##return {"obpm" => @obpm, "bpm" => @bpm , "new_obpm" => @season_obpm, "new_bpm" => @season_bpm, "lineup_id" => @lineup_id}
	end

	private 

	def steal_pct()

		steal_pct = Advanced::StealPctService.new({
			steals: @steals,
			team_minutes: @team_minutes,
			minutes: @minutes,
			opp_poss: @opp_possessions
		}).call


		season_stat = LineupAdvStat.where(stat_list_id: 35, lineup_id: @lineup_id).take
		if season_stat
			season_stat.value = steal_pct
			season_stat.save
		else

			LineupAdvStat.create({
				stat_list_id: 35,
				lineup_id: @lineup_id,
				value: steal_pct
			})
		end
	end

	def turnover_pct()
		## CORRECT
		turnover_pct = Advanced::TurnoverPctService.new({
			turnovers: @turnovers,
			field_goal_att: @field_goal_att,
			free_throw_att: @free_throw_att,
		}).call

		season_stat = LineupAdvStat.where(stat_list_id: 37, lineup_id: @lineup_id).take
		if season_stat
			season_stat.value = turnover_pct
			season_stat.save
		else
			LineupAdvStat.create({
				stat_list_id: 37,
				lineup_id: @lineup_id,
				value: turnover_pct
			})
		end
	end

	def offensive_rb_pct()
		## CORRECT
		offensive_rebound_pct = Advanced::OffensiveReboundPctService.new({
			off_reb: @off_reb,
			opp_def_reb: @opp_def_reb,
			team_minutes: @team_minutes,
			minutes: @minutes,
			team_off_reb: @team_off_reb
		}).call

		season_stat = LineupAdvStat.where(stat_list_id: 32, lineup_id: @lineup_id).take
		if season_stat

			season_stat.value = offensive_rebound_pct
			season_stat.save
		else
			LineupAdvStat.create({
				stat_list_id: 32,
				lineup_id: @lineup_id,
				value: offensive_rebound_pct
			})
		end
	end



	def total_reb_pct()
		total_rebound_pct = Advanced::TotalReboundPctService.new({
			total_reb: @total_reb,
			team_minutes: @team_minutes,
			minutes: @minutes,
			team_total_reb: @team_total_reb,
			opp_total_reb: @opp_total_reb,
		}).call

		season_stat = LineupAdvStat.where(stat_list_id: 34, lineup_id: @lineup_id).take
		if season_stat

			season_stat.value = total_rebound_pct
			season_stat.save
		else
			
			LineupAdvStat.create({
				stat_list_id: 34,
				lineup_id: @lineup_id,
				value: total_rebound_pct
			})
		end
	end

	def defensive_reb_pct()
		## CORRECT
		defensive_rebound_pct = Advanced::DefensiveReboundPctService.new({
			def_reb: @def_reb,
			opp_off_reb: @opp_off_reb,
			team_minutes: @team_minutes,
			minutes: @minutes,
			team_def_reb: @team_def_reb
		}).call

		season_stat = LineupAdvStat.where(stat_list_id: 33, lineup_id: @lineup_id).take
		if season_stat

			season_stat.value = defensive_rebound_pct
			season_stat.save
		else
			
			LineupAdvStat.create({
				stat_list_id: 33,
				lineup_id: @lineup_id,
				value: defensive_rebound_pct
			})
		end

	end

	def three_pt_attempt_rate()
		three_point_attempt_rate = Advanced::ThreePtAttemptRateService.new({
			three_point_att: @three_point_att,
			field_goal_att: @field_goal_att 
		}).call

		season_stat = LineupAdvStat.where(stat_list_id: 20, lineup_id: @lineup_id).take
		if season_stat

			season_stat.value = three_point_attempt_rate
			season_stat.save
		else
			
			LineupAdvStat.create({
				stat_list_id: 20,
				lineup_id: @lineup_id,
				value: three_point_attempt_rate
			})
		end
	end



	def free_throw_att_rate()
		free_throw_attempt_rate = Advanced::FreeThrowAttemptRateService.new({
			free_throw_att: @free_throw_att,
			field_goal_att: @field_goal_att
		}).call

		season_stat = LineupAdvStat.where(stat_list_id: 21, lineup_id: @lineup_id).take
		if season_stat
			season_stat.value = free_throw_attempt_rate
			season_stat.save
		else
			
			LineupAdvStat.create({
				stat_list_id: 21,
				lineup_id: @lineup_id,
				value: free_throw_attempt_rate
			})
		end
	end

	def effective_fg_pct()
		effective_fg_pct = Advanced::EffectiveFgPctService.new({
			field_goals: @field_goals,
			field_goal_att: @field_goal_att,
			three_point_fg: @three_point_fg,
		}).call

		season_stat = LineupAdvStat.where(stat_list_id: 18, lineup_id: @lineup_id).take
		if season_stat

			season_stat.value = effective_fg_pct
			season_stat.save
		else
			
			LineupAdvStat.create({
				stat_list_id: 18,
				lineup_id: @lineup_id,
				value: effective_fg_pct
			})
		end
	end

	def true_shooting()
		true_shooting = Advanced::TrueShootingPctService.new({
			points: @points,
			field_goal_att: @field_goal_att,
			free_throw_att: @free_throw_att,
		}).call

		season_stat = LineupAdvStat.where(stat_list_id: 19, lineup_id: @lineup_id).take
		if season_stat

			season_stat.value =true_shooting
			season_stat.save
		else
			
			LineupAdvStat.create({
				stat_list_id: 19,
				lineup_id: @lineup_id,
				value: true_shooting
			})
		end
	end



	







end
