

class Stats::ShootingStatsService
	def initialize(params)
		@field_goals = params[:field_goals]
		@field_goal_att = params[:field_goal_att]
		@free_throw_makes = params[:free_throw_makes]
		@free_throw_att = params[:free_throw_att]
		@three_point_fg = params[:three_point_fg]
		@three_point_att = params[:three_point_att]
		@game_id = params[:game_id]
		@member_id = params[:member_id]
		@season_id = params[:season_id]
		@create_hash = []
	end

	def call 
		fg_pct()
		ft_pct()
		three_point_pct()
		three_point_att()
		field_goal_att()
		free_throw_att()
		create_stats
	end

	private

	def fg_pct()
		if (@field_goal_att) == 0 
			field_goal_pct = 0 
		else 
			field_goal_pct = 100 * @field_goals/@field_goal_att
		end

		@create_hash.push({
			value: field_goal_pct,
			game_id: @game_id,
			stat_list_id: 26,
			member_id: @member_id,
			season_id: @season_id
		})
	end

	def ft_pct()
		if @free_throw_att == 0 
			free_throw_pct = 0 
		else 
			free_throw_pct = 100* @free_throw_makes/@free_throw_att
		end

		@create_hash.push({
			value: free_throw_pct,
			stat_list_id: 28,
			member_id: @member_id,
			game_id: @game_id,
			season_id: @season_id
		})

	end


	def three_point_pct()
		if @three_point_att == 0 
			three_point_pct = 0 
		else 
			three_point_pct = 100 * @three_point_fg/@three_point_att
		end

		@create_hash.push({
			value: three_point_pct,
			stat_list_id: 27,
			member_id: @member_id,
			game_id: @game_id,
			season_id: @season_id
		})
	end

	def three_point_att()
		@create_hash.push({
			value: @three_point_att,
			stat_list_id: 48,
			member_id: @member_id,
			game_id: @game_id,
			season_id: @season_id
		})
	end

	def field_goal_att()
		@create_hash.push({
			value: @field_goal_att,
			stat_list_id: 47,
			member_id: @member_id,
			game_id: @game_id,
			season_id: @season_id
		})
	end

	def free_throw_att()
		@create_hash.push({
			value: @free_throw_att,
			stat_list_id: 49,
			member_id: @member_id,
			game_id: @game_id,
			season_id: @season_id
		})
	end

	def create_stats
		Stat.import @create_hash
	end

end



		

		

		

		
		

		
		