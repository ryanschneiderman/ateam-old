

class Stats::Advanced::Player::SeasonAdvancedStatsService

	def initialize(params)
		@member_id = params[:member_id]
		@team_id = params[:team_id]
		@team = Team.find_by_id(@team_id)
		@member = Member.find_by_id(@member_id)
		@season_id = params[:season_id]

		team_stats = TeamStat.joins(:stat_list).select("team_stats.*, stat_lists.*").where("team_stats.season_id" => @season_id).sort_by{|e| e.stat_list_id}

		team_stats.each do |ts|
			init_team_stat(ts)
		end

		if @off_reb.present? && @def_reb.present?
			@total_reb = @off_reb + @def_reb
			@team_total_reb = @team_off_reb + @team_def_reb
			@opp_total_reb = @opp_def_reb + @team_off_reb
		end

		

		@field_goal_att = @field_goals + @field_goal_misses
		@team_field_goal_att = @team_field_goals + @team_field_goal_misses
		@opp_field_goal_att = @opp_field_goals + @opp_field_goal_misses
		@free_throw_att = @free_throw_makes + @free_throw_misses
		@team_free_throw_att = @team_free_throw_makes + @team_free_throw_misses
		@opp_free_throw_att = @opp_free_throw_makes + @opp_free_throw_misses
		@three_point_att = @three_point_fg + @three_point_miss
		@team_three_point_att = @team_three_point_fg + @team_three_point_miss
		@opp_three_point_att = @opp_three_point_fg + @opp_three_point_miss

		@create_hash = []
		@update_hash = []
	end

	def call
		advanced_stats = TeamStat.joins(:stat_list).select("stat_lists.advanced as advanced, team_stats.*").where("stat_lists.advanced" => true, "team_stats.season_id" => @season_id).sort_by{|e| e.stat_list_id}

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
			when 22
				usage_rate()
			when 23
				offensive_rating()
			when 24
				defensive_rating()
			when 25
				net_rating()
			when 32
				offensive_rb_pct()
			when 33
				defensive_reb_pct()
			when 34
				total_reb_pct()
			when 35
				steal_pct()
			when 36
				block_pct()
			when 37
				turnover_pct()
			when 38
				assist_pct()
			when 41
				box_plus_minus()
				off_box_plus_minus()
				def_box_plus_minus()
			end		
		end
		create_stats
		update_stats

		## return box plus minus values to adjust later
		return {"obpm" => @off_box_plus_minus, "bpm" => @box_plus_minus , "new_obpm" => @season_obpm, "new_bpm" => @season_bpm, "member_id" => @member_id}
	end

	private 

	def init_team_stat(team_stat)
		case team_stat.stat_list_id
		when 1
			@field_goals = SeasonStat.where(member_id: @member_id, stat_list_id: 1, season_id: @season_id).take.value
			@team_field_goals = TeamSeasonStat.where(stat_list_id: 1, is_opponent: false, season_id: @season_id).take.value
			@opp_field_goals =TeamSeasonStat.where(stat_list_id: 1, is_opponent: true, season_id: @season_id).take.value
		when 2
			@field_goal_misses = SeasonStat.where(member_id: @member_id, stat_list_id: 2, season_id: @season_id).take.value
			@team_field_goal_misses = TeamSeasonStat.where(stat_list_id: 2, is_opponent: false, season_id: @season_id).take.value
			@opp_field_goal_misses = TeamSeasonStat.where(stat_list_id: 2, is_opponent: true, season_id: @season_id).take.value
		when 3
			@assists = SeasonStat.where(member_id: @member_id, stat_list_id: 3, season_id: @season_id).take.value
			@team_assists = TeamSeasonStat.where(stat_list_id: 3, is_opponent: false, season_id: @season_id).take.value
			@opp_assists = TeamSeasonStat.where(stat_list_id: 3, is_opponent: true, season_id: @season_id).take.value
		when 4
			@off_reb = SeasonStat.where(member_id: @member_id, stat_list_id: 4, season_id: @season_id).take.value
			@team_off_reb = TeamSeasonStat.where(stat_list_id: 4, is_opponent: false, season_id: @season_id).take.value
			@opp_off_reb = TeamSeasonStat.where(stat_list_id: 4, is_opponent: true, season_id: @season_id).take.value
		when 5
			@def_reb = SeasonStat.where(member_id: @member_id, stat_list_id: 5, season_id: @season_id).take.value
			@team_def_reb = TeamSeasonStat.where(stat_list_id: 5, is_opponent: false, season_id: @season_id).take.value
			@opp_def_reb = TeamSeasonStat.where(stat_list_id: 5, is_opponent: true, season_id: @season_id).take.value
		when 6
			@steals = SeasonStat.where(member_id: @member_id, stat_list_id: 6, season_id: @season_id).take.value
			@team_steals = TeamSeasonStat.where(stat_list_id: 6, is_opponent: false, season_id: @season_id).take.value
			@opp_steals = TeamSeasonStat.where(stat_list_id: 6, is_opponent: true, season_id: @season_id).take.value
		when 7
			@turnovers =SeasonStat.where(member_id: @member_id, stat_list_id: 7, season_id: @season_id).take.value
			@team_turnovers = TeamSeasonStat.where(stat_list_id: 7, is_opponent: false, season_id: @season_id).take.value
			@opp_turnovers = TeamSeasonStat.where(stat_list_id: 7, is_opponent: true, season_id: @season_id).take.value
		when 8
			@blocks = SeasonStat.where(member_id: @member_id, stat_list_id: 8, season_id: @season_id).take.value
			@team_blocks = TeamSeasonStat.where(stat_list_id: 8, is_opponent: false, season_id: @season_id).take.value
			@opp_blocks = TeamSeasonStat.where(stat_list_id: 8, is_opponent: true, season_id: @season_id).take.value
		when 11
			@three_point_fg = SeasonStat.where(member_id: @member_id, stat_list_id: 11, season_id: @season_id).take.value
			@team_three_point_fg = TeamSeasonStat.where(stat_list_id: 11, is_opponent: false, season_id: @season_id).take.value
			@opp_three_point_fg = TeamSeasonStat.where(stat_list_id: 11, is_opponent: true, season_id: @season_id).take.value
		when 12
			@three_point_miss = SeasonStat.where(member_id: @member_id, stat_list_id: 12, season_id: @season_id).take.value
			@team_three_point_miss = TeamSeasonStat.where(stat_list_id: 12, is_opponent: false, season_id: @season_id).take.value
			@opp_three_point_miss = TeamSeasonStat.where(stat_list_id: 12, is_opponent: true, season_id: @season_id).take.value
		when 13
			@free_throw_makes = SeasonStat.where(member_id: @member_id, stat_list_id: 13, season_id: @season_id).take.value
			@team_free_throw_makes = TeamSeasonStat.where(stat_list_id: 13, is_opponent: false, season_id: @season_id).take.value
			@opp_free_throw_makes = TeamSeasonStat.where(stat_list_id: 13, is_opponent: true, season_id: @season_id).take.value
		when 14
			@free_throw_misses = SeasonStat.where(member_id: @member_id, stat_list_id: 14, season_id: @season_id).take.value
			@team_free_throw_misses = TeamSeasonStat.where(stat_list_id: 14, is_opponent: false, season_id: @season_id).take.value
			@opp_free_throw_misses = TeamSeasonStat.where(stat_list_id: 14, is_opponent: true, season_id: @season_id).take.value
		when 15
			@points = SeasonStat.where(member_id: @member_id, stat_list_id: 15, season_id: @season_id).take.value
			@team_points = TeamSeasonStat.where(stat_list_id: 15, is_opponent: false, season_id: @season_id).take.value
			@opp_points =  TeamSeasonStat.where(stat_list_id: 15, is_opponent: true, season_id: @season_id).take.value
		when 16
			@minutes = SeasonStat.where(member_id: @member_id, stat_list_id: 16, season_id: @season_id).take.value / 60.0
			@team_minutes =  TeamSeasonStat.where(stat_list_id: 16, is_opponent: false, season_id: @season_id).take.value / 60.0
			@opp_minutes = @team_minutes
		when 17
			@fouls = SeasonStat.where(member_id: @member_id, stat_list_id: 17, season_id: @season_id).take.value
			@team_fouls = TeamSeasonStat.where(stat_list_id: 17, is_opponent: false, season_id: @season_id).take.value
			@opp_fouls = TeamSeasonStat.where(stat_list_id: 17, is_opponent: true, season_id: @season_id).take.value
		when 42
			@possessions = SeasonTeamAdvStat.where(stat_list_id: 42, is_opponent: false, season_id: @season_id).take.value
			@opp_possessions = SeasonTeamAdvStat.where(stat_list_id: 42, is_opponent: true, season_id: @season_id).take.value
		end
	end

	def steal_pct()
		new_steal_pct = Stats::Advanced::Player::StealPctService.new({
			steals: @steals ,
			team_minutes: @team_minutes ,
			minutes: @minutes,
			opp_poss: @opp_possessions 
		}).call

		season_stat = SeasonAdvancedStat.where(stat_list_id: 35, member_id: @member_id, season_id: @season_id).take
		if season_stat
			season_stat.value = new_steal_pct
			@update_hash.push(season_stat)
		else
			@create_hash.push({
				stat_list_id: 35,
				member_id: @member_id,
				value: new_steal_pct,
				season_id: @season_id
			})
		end
	end

	def turnover_pct()
		new_tov_pct = Stats::Advanced::Player::TurnoverPctService.new({
			turnovers: @turnovers ,
			field_goal_att: @field_goal_att,
			free_throw_att: @free_throw_att ,
		}).call
		season_stat = SeasonAdvancedStat.where(stat_list_id: 37, member_id: @member_id, season_id: @season_id).take
		if season_stat
			season_stat.value = new_tov_pct
			@update_hash.push(season_stat)
		else
			@create_hash.push({
				stat_list_id: 37,
				member_id: @member_id,
				value: new_tov_pct,
				season_id: @season_id
			})
		end
	end

	def offensive_rb_pct()
		new_oreb_pct = Stats::Advanced::Player::OffensiveReboundPctService.new({
			off_reb: @off_reb,
			opp_def_reb: @opp_def_reb,
			team_minutes: @team_minutes,
			minutes: @minutes,
			team_off_reb: @team_off_reb,
		}).call
		season_stat = SeasonAdvancedStat.where(stat_list_id: 32, member_id: @member_id, season_id: @season_id).take
		if season_stat

			season_stat.value = new_oreb_pct
			@update_hash.push(season_stat)
		else
			@create_hash.push({
				stat_list_id: 32,
				member_id: @member_id,
				value: new_oreb_pct,
				season_id: @season_id
			})
		end
	end

	def block_pct()
		new_block_pct = Stats::Advanced::Player::BlockPctService.new({
			blocks: @blocks,
			team_minutes: @team_minutes,
			minutes: @minutes,
			opp_field_goal_att: @opp_field_goal_att,
			opp_three_point_att: @opp_three_point_att,
		}).call
		season_stat = SeasonAdvancedStat.where(stat_list_id: 36, member_id: @member_id, season_id: @season_id).take
		if season_stat

			season_stat.value = new_block_pct
			@update_hash.push(season_stat)
		else
			@create_hash.push({
				stat_list_id: 36,
				member_id: @member_id,
				value: new_block_pct,
				season_id: @season_id
			})
		end
	end

	def assist_pct()
		new_assist_pct = Stats::Advanced::Player::AssistPctService.new({
			assists: @assists,
			minutes: @minutes ,
			team_minutes: @team_minutes,
			team_field_goals: @team_field_goals,
			field_goals: @field_goals,
		}).call
		season_stat = SeasonAdvancedStat.where(stat_list_id: 38, member_id: @member_id, season_id: @season_id).take
		if season_stat

			season_stat.value = new_assist_pct
			@update_hash.push(season_stat)
		else
			@create_hash.push({
				stat_list_id: 38,
				member_id: @member_id,
				value: new_assist_pct,
				season_id: @season_id
			})
		end
	end

	def usage_rate()
		new_usage_rate = Stats::Advanced::Player::UsageRateService.new({
			field_goal_att: @field_goal_att,
			turnovers: @turnovers,
			free_throw_att: @free_throw_att,
			team_minutes: @team_minutes,
			minutes: @minutes,
			team_field_goal_att: @team_field_goal_att,
			team_turnovers: @team_turnovers,
			team_free_throw_att: @team_free_throw_att,
		}).call
		season_stat = SeasonAdvancedStat.where(stat_list_id: 22, member_id: @member_id,season_id: @season_id).take
		if season_stat

			season_stat.value = new_usage_rate
			@update_hash.push(season_stat)
		else
			@create_hash.push({
				stat_list_id: 22,
				member_id: @member_id,
				value: new_usage_rate,
				season_id: @season_id
			})
		end
	end

	def total_reb_pct()
		new_treb_pct = Stats::Advanced::TotalReboundPctService.new({
			total_reb: @total_reb,
			team_minutes: @team_minutes,
			minutes: @minutes,
			team_total_reb: @team_total_reb,
			opp_total_reb: @opp_total_reb,
		}).call

		season_stat = SeasonAdvancedStat.where(stat_list_id: 34, member_id: @member_id, season_id: @season_id).take
		if season_stat
			
			season_stat.value = new_treb_pct
			@update_hash.push(season_stat)
		else
			@create_hash.push({
				stat_list_id: 34,
				member_id: @member_id,
				value: new_treb_pct,
				season_id: @season_id
			})
		end
	end

	def defensive_reb_pct()
		new_def_reb_pct = Stats::Advanced::Player::DefensiveReboundPctService.new({
			def_reb: @def_reb,
			opp_off_reb: @opp_off_reb,
			team_minutes: @team_minutes,
			minutes: @minutes,
			team_def_reb: @team_def_reb,
		}).call
		season_stat = SeasonAdvancedStat.where(stat_list_id: 33, member_id: @member_id, season_id: @season_id).take
		if season_stat
			
			season_stat.value = new_def_reb_pct
			@update_hash.push(season_stat)
		else
			@create_hash.push({
				stat_list_id: 33,
				member_id: @member_id, 
				season_id: @season_id,
				value: new_def_reb_pct
			})
		end
	end

	def three_pt_attempt_rate()
		new_three_par = Stats::Advanced::ThreePtAttemptRateService.new({
			three_point_att: @three_point_att,
			field_goal_att: @field_goal_att,
		}).call
		season_stat = SeasonAdvancedStat.where(stat_list_id: 20, member_id: @member_id, season_id: @season_id).take
		if season_stat
			

			season_stat.value = new_three_par
			@update_hash.push(season_stat)
		else
			@create_hash.push({
				stat_list_id: 20,
				member_id: @member_id, 
				season_id: @season_id,
				value: new_three_par
			})
		end
	end

	def linear_per()
		new_per = Stats::Advanced::Player::LinearPerService.new({
			field_goals: @field_goals,
			steals: @steals,
			three_point_makes: @three_point_fg,
			free_throw_makes: @free_throw_makes ,
			blocks: @blocks ,
			off_reb: @off_reb ,
			assists: @assists ,
			def_reb: @def_reb,
			fouls: @fouls,
			free_throw_misses: @free_throw_misses ,
			field_goal_misses: @field_goal_misses ,
			turnovers: @turnovers,
			minutes: @minutes,
		}).call
		season_stat = SeasonAdvancedStat.where(stat_list_id: 20, member_id: @member_id, season_id: @season_id).take
		if season_stat
			

			season_stat.value = new_per
			@update_hash.push(season_stat)
		else
			@create_hash.push({
				stat_list_id: 20,
				member_id: @member_id, 
				season_id: @season_id,
				value: new_per
			})
		end
	end


	def free_throw_att_rate()
		new_ft_ar = Stats::Advanced::FreeThrowAttemptRateService.new({
			free_throw_att: @free_throw_att,
			field_goal_att: @field_goal_att,
		}).call

		season_stat = SeasonAdvancedStat.where(stat_list_id: 21, member_id: @member_id, season_id: @season_id).take
		if season_stat

			season_stat.value = new_ft_ar
			@update_hash.push(season_stat)
		else
			@create_hash.push({
				stat_list_id: 21,
				member_id: @member_id, 
				season_id: @season_id,
				value: new_ft_ar
			})
		end
	end

	def effective_fg_pct()
		new_eff_fg_pct = Stats::Advanced::EffectiveFgPctService.new({
			field_goals: @field_goals,
			field_goal_att: @field_goal_att,
			three_point_fg: @three_point_fg,
		}).call
		season_stat = SeasonAdvancedStat.where(stat_list_id: 18, member_id: @member_id, season_id: @season_id).take
		if season_stat

			season_stat.value = new_eff_fg_pct
			@update_hash.push(season_stat)
		else
			@create_hash.push({
				stat_list_id: 18,
				member_id: @member_id, 
				season_id: @season_id,
				value: new_eff_fg_pct
			})
		end
	end


	def true_shooting()
		true_shooting = Stats::Advanced::TrueShootingPctService.new({
			points: @points,
			field_goal_att: @field_goal_att,
			free_throw_att: @free_throw_att,
		}).call


		season_stat = SeasonAdvancedStat.where(stat_list_id: 19, member_id: @member_id, season_id: @season_id).take
		if season_stat
			season_stat.value = true_shooting
			@update_hash.push(season_stat)
		else
			@create_hash.push({
				stat_list_id: 19,
				member_id: @member_id, 
				season_id: @season_id,
				value: true_shooting
			})
		end
	end

	def defensive_rating()
		@defensive_rating = Stats::Advanced::Player::DefensiveRatingService.new({
			steals: @steals,
			team_steals: @team_steals,
			blocks: @blocks,
			team_blocks: @team_blocks,
			def_reb: @def_reb,
			team_def_reb: @team_def_reb,
			opp_off_reb: @opp_off_reb,
			opp_field_goals_made: @opp_field_goals,
			opp_field_goal_att: @opp_field_goal_att,
			minutes: @minutes,
			team_minutes: @team_minutes,
			opp_minutes: @opp_minutes,
			opp_turnovers: @opp_turnovers,
			fouls: @fouls,
			team_fouls: @team_fouls,
			opp_free_throw_att: @opp_free_throw_att,
			opp_free_throws_made: @opp_free_throw_makes,
			opp_points: @opp_points,
			opp_possessions: @opp_possessions
		}).call

		season_stat = SeasonAdvancedStat.where(stat_list_id: 24, member_id: @member_id, season_id: @season_id).take
		if season_stat
			season_stat.value = @defensive_rating
			@update_hash.push(season_stat)
		else	
			@create_hash.push({
				stat_list_id: 24,
				member_id: @member_id, 
				season_id: @season_id,
				value: @defensive_rating
			})
			@new_def_rtg = @defensive_rating
		end
	end

	def offensive_rating()
		@offensive_rating = Stats::Advanced::Player::OffensiveRatingService.new({
			team_off_reb: @team_off_reb,
			off_reb: @off_reb,
			opp_total_reb: @opp_def_reb + @opp_off_reb,
			opp_off_reb: @opp_off_reb,
			field_goals: @field_goals,
			team_field_goals: @team_field_goals,
			team_three_point_fg: @team_three_point_fg,
			three_point_fg: @three_point_fg,
			points: @points,
			team_points: @team_points,
			free_throw_att: @free_throw_att,
			free_throw_makes: @free_throw_makes,
			team_free_throw_att: @team_free_throw_att,
			team_free_throw_makes: @team_free_throw_makes,
			field_goal_att: @field_goal_att,
			team_field_goal_att: @team_field_goal_att,
			minutes: @minutes,
			team_minutes: @team_minutes,
			team_assists: @team_assists,
			assists: @assists,
			turnovers: @turnovers,
			team_turnovers: @team_turnovers,
		}).call

	
		season_stat = SeasonAdvancedStat.where(stat_list_id: 23, member_id: @member_id, season_id: @season_id).take
		if season_stat
			season_stat.value = @offensive_rating
			@update_hash.push(season_stat)
		else	
			@create_hash.push({
				stat_list_id: 23,
				member_id: @member_id, 
				season_id: @season_id,
				value: @offensive_rating
			})
			@new_off_rtg = @offensive_rating
		end
	end

	def net_rating()
		net_rating =  @offensive_rating - @defensive_rating
		net_rating = net_rating * 100
		net_rating = net_rating.round / 100.0

		season_stat = SeasonAdvancedStat.where(stat_list_id: 25, member_id: @member_id, season_id: @season_id).take
		if season_stat
			season_stat.value = net_rating
			@update_hash.push(season_stat)
		else
			@create_hash.push({
				stat_list_id: 25,
				member_id: @member_id, 
				season_id: @season_id,
				value: net_rating
			})
		end
	end

	def box_plus_minus()
		@box_plus_minus = Stats::Advanced::Player::BoxPlusMinusService.new({
			off_reb: @off_reb,
			def_reb: @def_reb,
			opp_def_reb: @opp_def_reb,
			opp_off_reb: @opp_off_reb,
			team_off_reb: @team_off_reb,
			team_def_reb: @team_def_reb,
			steals: @steals,
			minutes: @minutes,
			team_minutes: @team_minutes,
			opp_field_goal_att: @opp_field_goal_att,
			opp_field_goals: @opp_field_goals,
			opp_free_throw_att: @opp_free_throw_att,
			opp_three_point_att: @opp_three_point_att,
			blocks: @blocks,
			team_field_goals: @team_field_goals,
			field_goals: @field_goals,
			assists: @assists,
			turnovers: @turnovers,
			opp_turnovers: @opp_turnovers,
			free_throw_att: @free_throw_att,
			field_goal_att: @field_goal_att,
			team_turnovers: @team_turnovers,
			points: @points,
			team_points: @team_points,
			team_field_goal_att: @team_field_goal_att,
			team_free_throw_att: @team_free_throw_att,
			three_point_att: @three_point_att,
			team_three_point_att: @team_three_point_att,
			bpm_type: "regular",
			possessions: @possessions,
			opp_possessions: @opp_possessions
		}).call

		season_stat = SeasonAdvancedStat.where(stat_list_id: 43, member_id: @member_id, season_id: @season_id).take
		if season_stat

			season_stat.value = @box_plus_minus
			@update_hash.push(season_stat)
			@season_bpm = season_stat
		else	
			@create_hash.push({
				stat_list_id: 43,
				member_id: @member_id, 
				season_id: @season_id,
				value: @box_plus_minus
			})
			@new_bpm = @box_plus_minus
		end

	end

	def off_box_plus_minus()
		@off_box_plus_minus = Stats::Advanced::Player::BoxPlusMinusService.new({
			off_reb: @off_reb,
			def_reb: @def_reb,
			opp_def_reb: @opp_def_reb,
			opp_off_reb: @opp_off_reb,
			team_off_reb: @team_off_reb,
			team_def_reb: @team_def_reb,
			steals: @steals,
			minutes: @minutes,
			team_minutes: @team_minutes,
			opp_field_goal_att: @opp_field_goal_att,
			opp_field_goals: @opp_field_goals,
			opp_free_throw_att: @opp_free_throw_att,
			opp_three_point_att: @opp_three_point_att,
			blocks: @blocks,
			team_field_goals: @team_field_goals,
			field_goals: @field_goals,
			assists: @assists,
			turnovers: @turnovers,
			opp_turnovers: @opp_turnovers,
			free_throw_att: @free_throw_att,
			field_goal_att: @field_goal_att,
			team_turnovers: @team_turnovers,
			points: @points,
			team_points: @team_points,
			team_field_goal_att: @team_field_goal_att,
			team_free_throw_att: @team_free_throw_att,
			three_point_att: @three_point_att,
			team_three_point_att: @team_three_point_att,
			bpm_type: "offensive",
			possessions: @possessions,
			opp_possessions: @opp_possessions,
		}).call

		season_stat = SeasonAdvancedStat.where(stat_list_id: 44, member_id: @member_id, season_id: @season_id).take
		if season_stat

			season_stat.value = @off_box_plus_minus
			@update_hash.push(season_stat)
			@season_obpm = season_stat
		else	
			@create_hash.push({
				stat_list_id: 44,
				member_id: @member_id, 
				season_id: @season_id,
				value: @off_box_plus_minus
			})
			@new_obpm = @off_box_plus_minus
		end
	end

	def def_box_plus_minus()
		def_box_plus_minus = @box_plus_minus - @off_box_plus_minus
		def_box_plus_minus = def_box_plus_minus * 100
		def_box_plus_minus = def_box_plus_minus.round / 100.0

		season_stat = SeasonAdvancedStat.where(stat_list_id: 40, member_id: @member_id, season_id: @season_id).take
		if season_stat
			season_stat.value = def_box_plus_minus
			@update_hash.push(season_stat)
		else
			@create_hash.push({
				stat_list_id: 40,
				member_id: @member_id, season_id: @season_id,
				value: def_box_plus_minus
			})
		end
	end

	def create_stats
		if @create_hash.length > 0
			SeasonAdvancedStat.import @create_hash
		end
	end

	def update_stats
		if @update_hash.length > 0
			SeasonAdvancedStat.import @update_hash, on_duplicate_key_update: {conflict_target: [:id], columns: [:value, :updated_at]}
		end
	end
end
