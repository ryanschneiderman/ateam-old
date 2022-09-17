class TeamsController < ApplicationController
	
	def index
	end


	def new
		@team = Team.new
		@new_member = Member.new

		@small_header = true

		@stat_list_all = StatList.all
		gon.stat_lists = @stat_list_all


		@team_stat = TeamStat.new()
		## stats that user has to collect in order for the app to perform its basic functions
		@default_collectable = StatList.where(default_stat: true, collectable: true)
		gon.default_collectable = @default_collectable

		## stats the user may collect but arent required
		@non_default_collectable = StatList.where(default_stat: false, collectable: true)

		@default_basic = StatList.where(default_stat: true, rankable: true, advanced: false).sort_by{|stat| stat.id}

		## basic stats that the application automatically collects based on the default stats
		@default_application_basic = StatList.where(default_stat: true, collectable: false, advanced: false)
		gon.default_application_basic = @default_application_basic

		##advanced stats the application automatically collects based on the default stats
		@default_indiv_advanced = StatList.where(default_stat: true, advanced: true, team_stat: false)
		gon.default_indiv_advanced = @default_indiv_advanced

		## should be nil
		@default_team_advanced = StatList.where(default_stat: true, advanced: true, team_stat: true)

		## advanced stats the application may collect depending on non default stats collected
		@non_default_indiv_advanced = StatList.where(advanced: true, team_stat: false, default_stat: false, hidden: false)

		## advanced stats the application may collect depending on non default stats collected
		@non_default_team_advanced = StatList.where(advanced: true, team_stat: true, default_stat: false)

		@advanced_stats = Stats::Advanced::AdvStatDependenciesService.new({adv_stats: @non_default_indiv_advanced}).call
		gon.advanced_stats = @advanced_stats

		@team_advanced_stats = Stats::Advanced::TeamAdvStatDependenciesService.new({adv_stats: @non_default_team_advanced}).call
		gon.team_advanced_stats = @team_advanced_stats
		gon.default_team_advanced = @default_team_advanced

		## advanced team stats the application may collect depending on non default stats collected
		@team_advanced = StatList.where(advanced: true, team_stat: true)
	end

	def create
		team = Team.create({
			sport_id: 1,
			user_id: current_user.id,
			paid: true
		})

		season = Seasons::CreateSeasonService.new({
			team_id: team.id,
			team_name: params[:team_name],
			num_periods: params[:period_type],
			period_length: params[:period_length],
			primary_color: params[:primary_color],
			secondary_color: params[:secondary_color],
			multiple_year_bool: params[:multiple_year_bool],
			recurr_members: [],
			new_members: params[:members],
			team_stats: params[:team_stats],
			current_user: current_user
		}).call




		# if params[:multiple_year_bool] == "true"
		# 	year2 = Date.current.year + 1
		# else
		# 	year2 = nil
		# end

		# season = Season.create({
		# 	team_id: team.id,
		# 	year1: Date.current.year,
		# 	year2: year2,
		# 	team_name: params[:team_name],
		# 	num_periods: params[:period_type],
		# 	period_length: params[:period_length],
		# 	primary_color: params[:primary_color],
		# 	secondary_color: params[:secondary_color],
		# 	multiple_years_flag: params[:multiple_year_bool],
		# 	dirty_stats: false
		# })

		# same_name_seasons = Season.where(team_name: params[:team_name])

		# counter = 0
		# same_name_seasons.each do |s|
		# 	counter+=1
		# end

		# if counter > 0
		# 	username = params[:team_name] + counter.to_s
		# else
		# 	usernmae = params[:team_name]
		# end

		# season.update(username: username)

		# Teams::CreateTeamMembersService.new({
		# 	members: params[:members],
		# 	team_id: team.id,
		# 	season_id: season.id
		# }).call


		# admin = Member.create({
		# 	nickname: "Coach " + current_user.first_name,
		# 	user_id: current_user.id,
		# 	permissions: {"plays_view" => true, "plays_edit" => true, "schedule_view" => true, "schedule_edit" => true, "stats_view" => true, "stats_edit" => true, "settings_view" => true, "settings_edit" => true , "chat_access_read" => true, "chat_access_write" => true},
		# 	is_admin: true,
		# 	season_id: season.id
		# })

		# Assignment.create({
		# 	member_id: admin.id,
		# 	role_id: 2
		# })

		# Teams::TeamStatService.new({
		# 	team_stats: params[:team_stats],
		# 	team_id: team.id,
		# 	season_id: season.id
		# }).call

		Plays::CreateInitialPlaylistsService.new({
			team_id: team.id,
		}).call

		redirect_to team_season_path(team.id, season.id)
	end	

	def join

		roles = params[:member_type]
		team_username = params[:username]
		team_password = params[:password]
		
		## TODO: UPDATE ROLES
		team_id = JoinTeamService.new({
			roles: roles,
			team_username: team_username,
			team_password: team_password,
			current_user: current_user,
			root_path: root_path,
		}).call

		redirect_path = root_path

		if team_id 
			redirect_path = team_season_path(team_id, joined_team: true)
		end


		## eventually redirect to a place depending on if JoinTeamService returns a value
		redirect_to redirect_path
	end

	def join_member
		id_to_join = params[:member_id]
		member = Member.find_by_id(id_to_join)
		member.user_id = current_user.id 
		member.save
	end

	def destroy
		team = Team.find_by_id(params[:id])

		if(current_user.admin || current_user.id == team.user_id)
			seasons = Season.where(team_id: params[:id])
			seasons.each do |season|
				DeleteSeasonService.new({season_id: season.id}).call
			end
			team.destroy
		end
		redirect_to admin_path
	end

	private

	def team_params
		params.require(:team).permit(:name, :username, :password, :primary_color, :secondary_color)                  
	end

	

end
