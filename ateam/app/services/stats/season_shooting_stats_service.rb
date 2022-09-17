
## TODO: HASH!!!!!

class Stats::SeasonShootingStatsService
	def initialize(params)
		@member_id = params[:member_id]
		@season_id = params[:season_id]

		@season_field_goals =  SeasonStat.where(member_id: @member_id, stat_list_id: 1, season_id: @season_id).take.value
		@season_field_goal_misses =  SeasonStat.where(member_id: @member_id, stat_list_id: 2, season_id: @season_id).take.value
		@season_field_goal_att = @season_field_goals + @season_field_goal_misses

		@season_free_throw_makes =  SeasonStat.where(member_id: @member_id, stat_list_id: 13, season_id: @season_id).take.value
		@season_free_throw_misses =  SeasonStat.where(member_id: @member_id, stat_list_id: 14, season_id: @season_id).take.value
		@season_free_throw_att = @season_free_throw_makes + @season_free_throw_misses

		@season_three_point_fg =  SeasonStat.where(member_id: @member_id, stat_list_id: 11, season_id: @season_id).take.value
		@season_three_point_misses =  SeasonStat.where(member_id: @member_id, stat_list_id: 12, season_id: @season_id).take.value
		@season_three_point_att = @season_three_point_fg + @season_three_point_misses

		@create_hash = []
		@update_hash = []
	end

	def call 
		season_fg_pct()
		season_ft_pct()
		season_three_point_pct()
		season_three_point_att()
		season_field_goal_att()
		season_free_throw_att()
		create_stats
		update_stats
	end

	private

	def season_fg_pct()
		if (@season_field_goal_att) == 0 
			season_field_goal_pct = 0 
		else 
			season_field_goal_pct = 100 * @season_field_goals/@season_field_goal_att
		end

		season_total = SeasonStat.where(member_id: @member_id, stat_list_id: 26, season_id: @season_id).take
		if season_total 
			season_total.value = season_field_goal_pct
			@update_hash.push(season_total)
		else 
			@create_hash.push({
				value: season_field_goal_pct,
				stat_list_id: 26,
				member_id: @member_id,
				season_id: @season_id
			})
		end
	end

	def season_ft_pct()
		if @season_free_throw_att == 0 
			season_free_throw_pct = 0 
		else 
			season_free_throw_pct = 100 * @season_free_throw_makes/@season_free_throw_att
		end
		season_total = SeasonStat.where(member_id: @member_id, stat_list_id: 28, season_id: @season_id).take
		if season_total 
			season_total.value = season_free_throw_pct
			@update_hash.push(season_total)
		else 
			@create_hash.push({
				value: season_free_throw_pct,
				stat_list_id: 28,
				member_id: @member_id,
				season_id: @season_id
			})
		end
	end

	def season_three_point_pct()
		if @season_three_point_att == 0 
			season_three_point_pct = 0 
		else 
			season_three_point_pct = 100 * @season_three_point_fg/@season_three_point_att
		end
		season_total = SeasonStat.where(member_id: @member_id, stat_list_id: 27, season_id: @season_id).take
		if season_total 
			season_total.value = season_three_point_pct
			@update_hash.push(season_total)
		else 
			@create_hash.push({
				value: season_three_point_pct,
				stat_list_id: 27,
				member_id: @member_id,
				season_id: @season_id
			})
		end
	end

	def season_three_point_att()
		season_total = SeasonStat.where(member_id: @member_id, stat_list_id: 48, season_id: @season_id).take
		if season_total 
			season_total.value = @season_three_point_att
			@update_hash.push(season_total)
		else 
			@create_hash.push({
				value: @season_three_point_att,
				stat_list_id: 48,
				member_id: @member_id,
				season_id: @season_id
			})
		end
	end


	def season_field_goal_att()
		season_total = SeasonStat.where(member_id: @member_id, stat_list_id: 47, season_id: @season_id).take
		if season_total 
			season_total.value = @season_field_goal_att
			@update_hash.push(season_total)
		else 
			@create_hash.push({
				value: @season_field_goal_att,
				stat_list_id: 47,
				member_id: @member_id,
				season_id: @season_id
			})
		end
	end


	def season_free_throw_att()
		season_total = SeasonStat.where(member_id: @member_id, stat_list_id: 49, season_id: @season_id).take
		if season_total 
			season_total.value = @season_free_throw_att
			@update_hash.push(season_total)
		else 
			@create_hash.push({
				value: @season_free_throw_att,
				stat_list_id: 49,
				member_id: @member_id,
				season_id: @season_id
			})
		end
	end

	def create_stats
		if @create_hash.length > 0
			SeasonStat.import @create_hash
		end
	end

	def update_stats
		if @update_hash.length > 0
			SeasonStat.import @update_hash, on_duplicate_key_update: {conflict_target: [:id], columns: [:value, :updated_at]}
		end
	end
end



		

		

		

		
		

		
		