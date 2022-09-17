

class Stats::Advanced::AdvancedStatsService

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
		@fouls = params[:fouls].to_f 
		@team_fouls = params[:team_fouls].to_f 
		@opp_fouls = params[:opp_fouls].to_f 


		@member_id = params[:member_id]
		@game_id = params[:game_id]
		@team_id = params[:team_id]
		@season_id = params[:season_id]


		@possessions = params[:possessions]
		@opp_possessions = params[:opp_possessions]

		if @member_id == 4
			puts "PRINTING POSSESSIONS IN PLAYER ADVANCED"
			puts @possessions
			puts @opp_possessions
		end

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
		@create_hash = []

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

		create_stats()

		puts "OBPM"
		puts @obpm

		## return box plus minus values to adjust later
		return {"obpm" => @off_box_plus_minus, "bpm" => @box_plus_minus , "member_id" => @member_id}
	end

	private 

	def steal_pct()

		steal_pct = Stats::Advanced::Player::StealPctService.new({
			steals: @steals,
			team_minutes: @team_minutes,
			minutes: @minutes,
			opp_poss: @opp_possessions
		}).call
		
		@create_hash.push({
			stat_list_id: 35,
			member_id: @member_id,
			game_id: @game_id,
			value: steal_pct,
			season_id: @season_id
		})

	end

	def turnover_pct()
		## CORRECT
		turnover_pct = Stats::Advanced::Player::TurnoverPctService.new({
			turnovers: @turnovers,
			field_goal_att: @field_goal_att,
			free_throw_att: @free_throw_att,
		}).call
		
		@create_hash.push({
			stat_list_id: 37,
			member_id: @member_id,
			game_id: @game_id,
			value: turnover_pct,
			season_id: @season_id
		})
	end

	def offensive_rb_pct()
		## CORRECT
		offensive_rebound_pct = Stats::Advanced::Player::OffensiveReboundPctService.new({
			off_reb: @off_reb,
			opp_def_reb: @opp_def_reb,
			team_minutes: @team_minutes,
			minutes: @minutes,
			team_off_reb: @team_off_reb
		}).call

		@create_hash.push({
			stat_list_id: 32,
			member_id: @member_id,
			game_id: @game_id,
			value: offensive_rebound_pct,
			season_id: @season_id
		})

	end

	def block_pct()
		## CORRECT
		block_pct = Stats::Advanced::Player::BlockPctService.new({
			blocks: @blocks,
			team_minutes: @team_minutes,
			minutes: @minutes,
			opp_field_goal_att: @opp_field_goal_att,
			opp_three_point_att: @opp_three_point_att,
		}).call

		@create_hash.push({
			stat_list_id: 36,
			member_id: @member_id,
			game_id: @game_id,
			value: block_pct,
			season_id: @season_id
		})

	end

	def assist_pct()
		## CORRECT
		assist_pct = Stats::Advanced::Player::AssistPctService.new({
			assists: @assists,
			minutes: @minutes,
			team_minutes: @team_minutes,
			team_field_goals: @team_field_goals,
			field_goals: @field_goals,
		}).call

		@create_hash.push({
			stat_list_id: 38,
			member_id: @member_id,
			game_id: @game_id,
			value: assist_pct,
			season_id: @season_id
		})

	end

	def usage_rate()
		## CORRECT
		usage_rate = Stats::Advanced::Player::UsageRateService.new({
			field_goal_att: @field_goal_att,
			turnovers: @turnovers,
			free_throw_att: @free_throw_att,
			team_minutes: @team_minutes,
			minutes: @minutes,
			team_field_goal_att: @team_field_goal_att,
			team_turnovers: @team_turnovers,
			team_free_throw_att: @team_free_throw_att,
		}).call

		@create_hash.push({
			stat_list_id: 22,
			member_id: @member_id,
			game_id: @game_id,
			value: usage_rate,
			season_id: @season_id
		})

	end

	def total_reb_pct()
		total_rebound_pct = Stats::Advanced::TotalReboundPctService.new({
			total_reb: @total_reb,
			team_minutes: @team_minutes,
			minutes: @minutes,
			team_total_reb: @team_total_reb,
			opp_total_reb: @opp_total_reb,
		}).call

		@create_hash.push({
			stat_list_id: 34,
			member_id: @member_id,
			game_id: @game_id,
			value: total_rebound_pct,
			season_id: @season_id
		})

	end

	def defensive_reb_pct()
		## CORRECT
		defensive_rebound_pct = Stats::Advanced::Player::DefensiveReboundPctService.new({
			def_reb: @def_reb,
			opp_off_reb: @opp_off_reb,
			team_minutes: @team_minutes,
			minutes: @minutes,
			team_def_reb: @team_def_reb
		}).call

		@create_hash.push({
			stat_list_id: 33,
			member_id: @member_id,
			game_id: @game_id,
			value: defensive_rebound_pct,
			season_id: @season_id
		})


	end

	def three_pt_attempt_rate()
		three_point_attempt_rate = Stats::Advanced::ThreePtAttemptRateService.new({
			three_point_att: @three_point_att,
			field_goal_att: @field_goal_att 
		}).call

		@create_hash.push({
			stat_list_id: 20,
			member_id: @member_id, 
			season_id: @season_id,
			game_id: @game_id,
			value: three_point_attempt_rate
		})

	end

	def linear_per()
		linear_per = Stats::Advanced::Player::LinearPerService.new({
			field_goals: @field_goals,
			steals: @steals,
			three_point_makes: @three_point_fg,
			free_throw_makes: @free_throw_makes,
			blocks: @blocks,
			off_reb: @off_reb,
			assists: @assists,
			def_reb: @def_reb,
			fouls: @fouls,
			free_throw_misses: @free_throw_misses,
			field_goal_misses: @field_goal_misses,
			turnovers: @turnovers,
			minutes: @minutes
		}).call

		@create_hash.push({
			stat_list_id: 20,
			member_id: @member_id, 
			season_id: @season_id,
			game_id: @game_id,
			value: linear_per
		})


	end


	def free_throw_att_rate()
		free_throw_attempt_rate = Stats::Advanced::FreeThrowAttemptRateService.new({
			free_throw_att: @free_throw_att,
			field_goal_att: @field_goal_att
		}).call

		@create_hash.push({
			stat_list_id: 21,
			member_id: @member_id, 
			season_id: @season_id,
			game_id: @game_id,
			value: free_throw_attempt_rate
		})

	end

	def effective_fg_pct()
		effective_fg_pct = Stats::Advanced::EffectiveFgPctService.new({
			field_goals: @field_goals,
			field_goal_att: @field_goal_att,
			three_point_fg: @three_point_fg,
		}).call

		@create_hash.push({
			stat_list_id: 18,
			member_id: @member_id, 
			season_id: @season_id,
			game_id: @game_id,
			value: effective_fg_pct
		})

	end

	def true_shooting()
		true_shooting = Stats::Advanced::TrueShootingPctService.new({
			points: @points,
			field_goal_att: @field_goal_att,
			free_throw_att: @free_throw_att,
		}).call

		@create_hash.push({
			stat_list_id: 19,
			member_id: @member_id, 
			season_id: @season_id,
			game_id: @game_id,
			value: true_shooting
		})

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

		@create_hash.push({
			stat_list_id: 24,
			member_id: @member_id, 
			season_id: @season_id,
			game_id: @game_id,
			value: @defensive_rating
		})

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

		@create_hash.push({
			stat_list_id: 23,
			member_id: @member_id, 
			season_id: @season_id,
			game_id: @game_id,
			value: @offensive_rating
		})

	end

	def net_rating()
		net_rating =  @offensive_rating - @defensive_rating
		net_rating = net_rating * 100
		net_rating = net_rating.round / 100.0
			
		@create_hash.push({
			stat_list_id: 25,
			member_id: @member_id, 
			season_id: @season_id,
			game_id: @game_id,
			value: net_rating
		})

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

		@create_hash.push({
			stat_list_id: 43,
			member_id: @member_id, 
			season_id: @season_id,
			game_id: @game_id,
			value: @box_plus_minus
		})


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

		@create_hash.push({
			stat_list_id: 44,
			member_id: @member_id, 
			season_id: @season_id,
			game_id: @game_id,
			value: @off_box_plus_minus
		})
	end

	def def_box_plus_minus()
		def_box_plus_minus = @box_plus_minus - @off_box_plus_minus
		def_box_plus_minus = def_box_plus_minus * 100
		def_box_plus_minus = def_box_plus_minus.round / 100.0

		@create_hash.push({
			stat_list_id: 40,
			member_id: @member_id, 
			season_id: @season_id,
			game_id: @game_id,
			value: def_box_plus_minus
		})


	end

	def create_stats
		AdvancedStat.import @create_hash
	end


end
