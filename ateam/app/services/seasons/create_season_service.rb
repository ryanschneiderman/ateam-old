class Seasons::CreateSeasonService
	def initialize(params)
		@team_id = params[:team_id]
		@team_name = params[:team_name]
		@num_periods = params[:num_periods]
		@period_length = params[:period_length]
		@primary_color = params[:primary_color]
		@secondary_color = params[:secondary_color]
		@multiple_year_bool = params[:multiple_year_bool]
		@recurr_members = params[:recurr_members]
		@new_members = params[:new_members]
		@team_stats = params[:team_stats]
		@current_user = params[:current_user]
		@old_season = params[:old_season]
	end

	def call
		if @multiple_year_bool == "true"
			year2 = Date.current.year + 1
		else
			year2 = nil
		end

		season = Season.new({
			team_id: @team_id,
			year1: Date.current.year,
			year2: year2,
			team_name: @team_name,
			num_periods: @num_periods,
			period_length: @period_length,
			primary_color: @primary_color,
			secondary_color: @secondary_color,
			dirty_stats: false,
			multiple_years_flag: @multiple_year_bool,
		})

		season.save!

		

		same_name_seasons = Season.where(team_name: @team_name)

		counter = 0
		same_name_seasons.each do |s|
			counter+=1
		end

		if counter > 1
			username = @team_name + counter.to_s
		else
			username = @team_name
		end

		season.update(username: username)

		Seasons::RecurringMembersService.new({
			members: @recurr_members,
			team_id: @team_id,
			season_id: season.id,
			old_season: @old_season
		}).call


		Teams::CreateTeamMembersService.new({
			members: @new_members,
			team_id: @team_id,
			season_id: season.id
		}).call

		admin = Member.create({
			nickname: "Coach " + @current_user.first_name,
			user_id: @current_user.id,
			permissions: {"plays_view" => true, "plays_edit" => true, "schedule_view" => true, "schedule_edit" => true, "stats_view" => true, "stats_edit" => true, "settings_view" => true, "settings_edit" => true, "chat_access_read" => true, "chat_access_write" => true },
			is_admin: true,
			season_id: season.id
		})

		old_member = Member.where(user_id: @current_user.id, season_id: @old_season).take
		if old_member.present?
			plays_views = PlayView.where(member_id: old_member.id)
			plays_views.each do |pv|
				play = PlayView.new({
					play_id: pv.play_id,
					member_id: admin.id,
					viewed: pv.viewed
				})
				play.save!
			end
		end

		Assignment.create({
			member_id: admin.id,
			role_id: 2
		})


		Teams::TeamStatService.new({
			team_stats: @team_stats,
			team_id: @team_id,
			season_id: season.id
		}).call

		return season

	end

	private 


end





