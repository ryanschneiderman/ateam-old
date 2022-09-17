class SettingsController < ApplicationController
	before_action :verify_team_paid, :authenticate_member, :verify_member
	def index
		curr_members =  Assignment.joins(:role).joins(:member).select("roles.name as role_name, members.*").where("members.user_id" => current_user.id, "members.season_id" => params[:season_id]).sort_by{|e| e.season_id}.reverse!
		@curr_member = curr_members.first

		@team_id = params[:team_id]
		@season_id = params[:season_id]

		## all non_default collectable stats that don't belong to a team,, default_stat: false, collectable: true
		@non_default_collectable_belongs = TeamStat.joins(:stat_list).select("stat_lists.*, team_stats.*").where("stat_lists.default_stat" => false, "stat_lists.collectable" => true, "team_stats.season_id" => @season_id).sort_by{|e| e.stat_list_id}
		non_default_collectable =  StatList.where(default_stat: false, collectable: true)
		@non_default_collectable_add = []
		non_default_collectable.each do |stat| 
			add_stat = @non_default_collectable_belongs.none?{|s| s.stat_list_id == stat.id}
			if add_stat 
				@non_default_collectable_add.push(stat)
			end
		end

		@non_default_advanced_belongs = TeamStat.joins(:stat_list).select("stat_lists.*, team_stats.*").where("stat_lists.default_stat" => false, "stat_lists.advanced" => true, "stat_lists.team_stat" => false, "team_stats.season_id" => @season_id).sort_by{|e| e.stat_list_id}
		non_default_advanced = StatList.where(advanced: true, team_stat: false, default_stat: false, hidden: false)
		@non_default_advanced_add = []
		non_default_advanced.each do |stat|
			add_stat = @non_default_advanced_belongs.none?{|s| s.stat_list_id == stat.id}
			if add_stat
				@non_default_advanced_add.push(stat)
			end
		end

		@non_default_team_advanced_belongs = TeamStat.joins(:stat_list).select("stat_lists.*, team_stats.*").where("stat_lists.default_stat" => false, "stat_lists.advanced" => true, "stat_lists.team_stat" => true, "team_stats.season_id" => @season_id).sort_by{|e| e.stat_list_id}
		
		non_default_team_advanced = StatList.where(advanced: true, team_stat: true, default_stat: false)
		@non_default_team_advanced_add = []
		non_default_team_advanced.each do |stat|
			puts stat.stat
			add_stat = @non_default_team_advanced_belongs.none?{|s| s.stat_list_id == stat.id}
			if add_stat
				@non_default_team_advanced_add.push(stat)
			end
		end


		@default_collectable = StatList.where(default_stat: true, collectable: true)
		@default_basic = StatList.where(default_stat: true, rankable: true, advanced: false).sort_by{|stat| stat.id}
		@default_application_basic = StatList.where(default_stat: true, collectable: false, advanced: false)
		@default_indiv_advanced = StatList.where(default_stat: true, advanced: true, team_stat: false)
		@default_team_advanced = StatList.where(default_stat: true, advanced: true, team_stat: true)
		@non_default_indiv_advanced = StatList.where(advanced: true, team_stat: false, default_stat: false, hidden: false)
		@non_default_team_advanced = StatList.where(advanced: true, team_stat: true, default_stat: false, hidden: false)

		@advanced_stats = Stats::Advanced::AdvStatDependenciesService.new({adv_stats: @non_default_indiv_advanced}).call

		@team_advanced_stats = Stats::Advanced::TeamAdvStatDependenciesService.new({adv_stats: @non_default_team_advanced}).call


		gon.default_collectable = @default_collectable
		gon.default_application_basic = @default_application_basic
		gon.default_indiv_advanced = @default_indiv_advanced
		gon.advanced_stats = @advanced_stats
		gon.team_advanced_stats = @team_advanced_stats
		gon.non_default_collectable_belongs = @non_default_collectable_belongs


		######## MEMBERS ########
		@team = Team.find_by_id(@team_id)
		@season = Season.find_by_id(params[:season_id])
		gon.season = @season
		gon.season_id = params[:season_id]
		gon.team_id = @team.id

		members = Assignment.joins(:role).joins(:member).select("roles.id as role_id, roles.name as role_name, members.*, members.nickname as name").where("members.season_id" => params[:season_id])

		gon.members = members
	end

	def update
		stats_to_add = params[:stats_to_add]
		stats_to_remove = params[:stats_to_remove]
		season_id = params[:season_id]

		new_members = params[:new_members]
		remove_members = params[:remove_members]
		update_members = params[:update_members]

		season = Season.find_by_id(season_id)
		if params[:multiple_year_bool] == "true"
			year2 = season.year1 + 1
		else
			year2 = nil
		end
		season.update(team_name: params[:team_name], num_periods: params[:period_type], period_length: params[:period_length], primary_color: params[:primary_color], secondary_color: params[:secondary_color], multiple_years_flag: params[:multiple_year_bool], year2: year2)
		
		
		Teams::CreateTeamMembersService.new({
			members: new_members,
			team_id: params[:team_id],
			season_id: params[:season_id]
		}).call

		Teams::UpdateMembersService.new({
			members: params[:update_members],
			team_id: params[:team_id],
			season_id: params[:season_id]
		}).call
		
		(remove_members || []).each do |member|
			assignment = Assignment.where(member_id: member[1][:id]).take
			assignment.destroy()
		end


		Teams::TeamStatService.new({
			team_stats: stats_to_add,
			team_id: params[:team_id],
			season_id: season_id
		}).call

		(stats_to_remove || []).each do |stat_id|
			team_stat = TeamStat.where(stat_list_id: stat_id, season_id: season_id).take
			if team_stat 
				TeamStat.destroy(team_stat.id)
			end
		end

		redirect_to team_season_settings_path(params[:team_id], season_id)
	end

	private 

	def verify_member
		curr_member = Member.where("members.user_id" => current_user.id, "members.season_id" => params[:season_id]).take
		if curr_member.nil? && !current_user.admin
			redirect_to root_path
		end
	end

	def verify_team_paid
		season = Season.find_by_id(params[:season_id])
		team = Team.find_by_id(season.team_id)
		if !team.paid
			redirect_to no_access_path
		end
	end

	def authenticate_member
		member = Member.where(user_id: current_user.id, season_id: params[:season_id]).take
		if !member && current_user.admin 
			@settings_write = true
			@settings_read = true
		else
			@settings_write = member.permissions["settings_edit"]
			@settings_read = member.permissions["settings_view"]
		end
		
		gon.settings_write = @settings_write
		gon.settings_read = @settings_read
	end
end
