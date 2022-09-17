
## TODO: HASH!!!!!

class Stats::Lineups::LineupShootingStatsService
	def initialize(params)
		@lineup_id = params[:lineup_id]
		@season_id = params[:season_id]
		@field_goals = LineupStat.where(lineup_id: @lineup_id, season_id: @season_id, stat_list_id: 1).take.value
		@field_goal_misses = LineupStat.where(lineup_id: @lineup_id, season_id: @season_id, stat_list_id: 2).take.value
		@field_goal_att = @field_goals + @field_goal_misses
		@free_throw_makes = LineupStat.where(lineup_id: @lineup_id, season_id: @season_id, stat_list_id: 13).take.value
		@free_throw_misses = LineupStat.where(lineup_id: @lineup_id, season_id: @season_id, stat_list_id: 14).take.value
		@free_throw_att = @free_throw_makes + @free_throw_misses
		@three_point_fg = LineupStat.where(lineup_id: @lineup_id, season_id: @season_id, stat_list_id: 11).take.value
		@three_point_misses = LineupStat.where(lineup_id: @lineup_id, season_id: @season_id, stat_list_id: 12).take.value
		@three_point_att = @three_point_fg + @three_point_misses
		@lineup_stats_hash = []
		@update_hash = []

	end

	def call 
		fg_pct()
		ft_pct()
		three_point_pct()
		three_point_att()
		field_goal_att()
		free_throw_att()
		create_stats 
		update_stats
	end

	private

	def fg_pct()
		if (@field_goal_att) == 0 
			field_goal_pct = 0 
		else 
			field_goal_pct = 100 * @field_goals/@field_goal_att
		end

		season_stat = LineupStat.where(lineup_id: @lineup_id, stat_list_id: 26, is_opponent: false, season_id: @season_id).take

		if season_stat 
			season_stat.value = field_goal_pct
			@update_hash.push(season_stat)
		else 
			@lineup_stats_hash.push({
				value: field_goal_pct,
				stat_list_id: 26,
				lineup_id: @lineup_id,
				is_opponent: false,
				season_id: @season_id
			})
		end
	end


	def ft_pct()
		if @free_throw_att == 0 
			free_throw_pct = 0 
		else 
			free_throw_pct = 100* @free_throw_makes/@free_throw_att
		end

		season_stat = LineupStat.where(lineup_id: @lineup_id, stat_list_id: 28, is_opponent: false, season_id: @season_id).take

		if season_stat 
			season_stat.value = free_throw_pct
			@update_hash.push(season_stat)
		else 
			@lineup_stats_hash.push({
				value: free_throw_pct,
				stat_list_id: 28,
				lineup_id: @lineup_id,
				is_opponent: false,
				season_id: @season_id
			})
		end

		
	end


	def three_point_pct()
		if @three_point_att == 0 
			three_point_pct = 0 
		else 
			three_point_pct = 100 * @three_point_fg/@three_point_att
		end

		season_stat = LineupStat.where(lineup_id: @lineup_id, stat_list_id: 27, is_opponent: false, season_id: @season_id).take

		if season_stat 
			season_stat.value = three_point_pct
			@update_hash.push(season_stat)
		else 
			@lineup_stats_hash.push({
				value: three_point_pct,
				stat_list_id: 27,
				lineup_id: @lineup_id,
				is_opponent: false,
				season_id: @season_id
			})
		end
		
	end


	def three_point_att()
		season_stat = LineupStat.where(lineup_id: @lineup_id, stat_list_id: 48, is_opponent: false, season_id: @season_id).take

		if season_stat 
			season_stat.value = @three_point_att
			@update_hash.push(season_stat)
		else 
			@lineup_stats_hash.push({
				value: @three_point_att,
				stat_list_id: 48,
				lineup_id: @lineup_id,
				is_opponent: false,
				season_id: @season_id
			})
		end
	end

	def field_goal_att()
		season_stat = LineupStat.where(lineup_id: @lineup_id, stat_list_id: 47, is_opponent: false, season_id: @season_id).take

		if season_stat 
			season_stat.value = @field_goal_att
			@update_hash.push(season_stat)
		else 
			@lineup_stats_hash.push({
				value: @field_goal_att,
				stat_list_id: 47,
				lineup_id: @lineup_id,
				is_opponent: false,
				season_id: @season_id
			})
		end
		
	end


	def free_throw_att()
		season_stat = LineupStat.where(lineup_id: @lineup_id, stat_list_id: 51, is_opponent: false, season_id: @season_id).take

		if season_stat 
			season_stat.value = @free_throw_att
			@update_hash.push(season_stat)
		else 
			@lineup_stats_hash.push({
				value: @free_throw_att,
				stat_list_id: 51,
				lineup_id: @lineup_id,
				is_opponent: false,
				season_id: @season_id
			})
		end
	end

	def create_stats
		if @lineup_stats_hash.length > 0
			LineupStat.import @lineup_stats_hash
		end
	end

	def update_stats
		if @update_hash.length > 0
			LineupStat.import @update_hash, on_duplicate_key_update: {conflict_target: [:id], columns: [:value, :updated_at]}
		end
	end

end



		

		

		

		
		

		
		