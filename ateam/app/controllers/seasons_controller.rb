class SeasonsController < ApplicationController
	before_action :verify_member, :verify_team_paid
	skip_before_action :verify_member, only: [:join, :join_season, :join_season_alt]
	skip_before_action :verify_team_paid, only: [:join, :join_season, :join_season_alt]
	def index
	end

	def show
		# InsertPlayTypesService.new().call
		@curr_member =  Assignment.joins(:role).joins(:member).select("roles.name as role_name, roles.id as role_id, members.*").where("members.user_id" => current_user.id, "members.season_id" => params[:id]).take
		
		if !@curr_member && current_user.admin 
			@curr_member = Assignment.joins(:role).joins(:member).select("roles.name as role_name, roles.id as role_id, members.*").where("members.season_id" => params[:id]).take
		end
		@non_user_members = nil
		@season_id = params[:id]
		@season = Season.find_by_id(params[:id])
		cookies[:season_id] = params[:id]

		@date = Date.today
		@day_of_week = day_of_week(@date.wday)
		@month_string = month_string(@date.month).upcase
		@day_number = @date.day
		@year = @date.year
		@is_game = false
		@is_practice = false

		@team_id = params[:team_id]

		@team = Team.find_by_id(@team_id)

		@schedule_event = ScheduleEvent.where(date: @date, season_id: @season_id).take
		if @schedule_event
			@schedule_event_place = @schedule_event.place
			@schedule_event_time = @schedule_event.time
			@schedule_time_parsed = convert_time_readable(@schedule_event_time)
			@game = Game.where(schedule_event_id: @schedule_event.id).take
			if @game 
				@opponent = Opponent.find_by_id(@game.opponent_id)
				@opponent_name = @opponent.name
				@is_game = true
			end
			@practice = Practice.where(schedule_event_id: @schedule_event.id)
			@is_practice = true
		else
			puts "no event"
		end

		gon.season_id = params[:id]
		gon.team_id = params[:team_id]
		gon.is_game = @is_game
		gon.is_practice = @is_practice
		gon.curr_member = @curr_member

		

		@recently_viewed = Play.joins(:team_plays, :play_views).select("plays.*, team_plays.team_id as team_id, play_views.member_id as member_id, play_views.viewed as viewed").where("team_plays.team_id" => params[:team_id], "plays.deleted_flag" => false, "play_views.member_id" => @curr_member.id).sort_by{|e| e.viewed}.reverse!.first(3)
		@recently_viewed_progressions = []
		@recently_viewed.each do |play|
			recently_viewed_progression = Progression.where(:play_id => play.id).sort_by{|e| e.index}
			@recently_viewed_progressions.append(recently_viewed_progression)
		end

		# Seasons::PlayViewService.new({
		# 	team_id: params[:team_id],
		# 	season_id: params[:id],
		# }).call

		# all_games = Game.where(season_id: params[:id])

		# all_games.each do |game|
		# 	team_points = StatTotal.where(game_id: game.id, stat_list_id: 15, is_opponent: false).take.value
		# 	opponent_points = StatTotal.where(game_id: game.id, stat_list_id: 15, is_opponent: true).take.value
		# 	if team_points > opponent_points
		# 		game.update(result: 1)
		# 	else
		# 		game.update(result: 0)
		# 	end
		# end



		@wins = Game.where(result: 1, season_id: params[:id]).length
		@losses = Game.where(result: 0, season_id: params[:id]).length



		if Game.where(season_id: params[:id], played: true).length > 0
			@previous_game = Game.where(season_id: params[:id], played: true).sort_by{|e| e.updated_at}.reverse[0]
			if @previous_game
				@previous_game_opponent = Opponent.find_by_id(@previous_game.opponent_id)
				@team_points = StatTotal.where(game_id: @previous_game.id, stat_list_id: 15, is_opponent: false).take.value
				@opponent_points = StatTotal.where(game_id: @previous_game.id, stat_list_id: 15, is_opponent: true).take.value
				@previous_game_point_leader = Stat.joins(:member).select("stats.*, members.nickname as nickname").where(game_id: @previous_game.id, stat_list_id: 15).order("value DESC").first
				@previous_game_minutes_leader = Stat.joins(:member).select("stats.*, members.nickname as nickname").where(game_id: @previous_game.id, stat_list_id: 16).order("value DESC").first
				@previous_game_assists_leader = Stat.joins(:member).select("stats.*, members.nickname as nickname").where(game_id: @previous_game.id, stat_list_id: 3).order("value DESC").first
				
				previous_game_rebounds = Stat.joins(:member).select("stats.*, members.nickname as nickname").where(game_id: @previous_game.id).where(stat_list_id: [4,5])
				total_rebounds_high = 0
				rebound_leader = ""
				previous_game_rebounds.group_by(&:member_id).each do |member_id, stats|
					if stats[0].present?
						if stats[1].present?
							total_rebounds = stats[0].value + stats[1].value
						else
							total_rebounds = stats[0].value
						end
					elsif stats[1].present
						total_rebounds = stats[1].value
					end

					if total_rebounds > total_rebounds_high
						total_rebounds_high = total_rebounds
						rebound_leader = stats[0].nickname
					end
				end
				@rebound_leader_name = rebound_leader
				@rebound_leader_value = total_rebounds_high
				
			end

			@offensive_rating = SeasonTeamAdvStat.select("*").joins(:stat_list).where(season_id: params[:id], stat_list_id: 29)
			@defensive_rating = SeasonTeamAdvStat.select("*").joins(:stat_list).where(season_id: params[:id], stat_list_id: 30)
			@team_stats = TeamSeasonStat.select("*").joins(:stat_list).where( is_opponent: false, season_id: params[:id])
			gon.team_stats = @team_stats
			gon.offensive_rating = @offensive_rating
			gon.defensive_rating = @defensive_rating


			@offensive_rating_lineup = SeasonIndex::LineupStatsService.new({team_id: params[:team_id], season_id: params[:id], stat_list_id: 29}).call
			gon.offensive_rating_lineup = @offensive_rating_lineup

			@defensive_rating_lineup = SeasonIndex::LineupStatsService.new({team_id: params[:team_id], season_id: params[:id], stat_list_id: 30}).call
			gon.defensive_rating_lineup = @defensive_rating_lineup

			@net_rating_lineup = SeasonIndex::LineupStatsService.new({team_id: params[:team_id], season_id: params[:id], stat_list_id: 25}).call
			gon.net_rating_lineup = @net_rating_lineup



			gon.team_points = @team_points
			gon.opponent_points = @opponent_points
		end

		permission = {"plays_view" => true, "plays_edit" => true, "schedule_view" => true, "schedule_edit" => true, "stats_view" => true, "stats_edit" => true, "settings_view" => true, "settings_edit" => true , "chat_access_read" => true, "chat_access_write" => true}

		# member = Member.find_by_id(@curr_member.id)
		# member.update(:permissions=> permission)
		# member.update(:nickname => "Coach Brad")
		# current_user.update(:first_name => "Admin")

		@write_permiss = @curr_member.permissions["chat_access_write"]
		@read_permiss = @curr_member.permissions["chat_access_read"]

		gon.write_permiss = @write_permiss
		gon.read_permiss = @read_permiss




		@post_objs = []
		@posts = Role.joins(members: [:posts, :assignments]).select("members.*, members.id as member_id, posts.id as post_id, posts.created_at as post_created_at, posts.content as content, roles.id as role_id, roles.name as role_name").where("members.season_id" => params[:id], "roles.id" => [1,2]).uniq { |item| item.post_id }.sort_by{|post| post.post_id}
		
		@posts.each do |post|
			comments = Role.joins(members: [:comments, :assignments]).select("members.*, comments.id as comment_id, comments.post_id as post_id, comments.created_at as comment_created_at, comments.content as content, roles.id as role_id, roles.name as role_name").where("comments.post_id" => post.post_id, "roles.id" => [1,2]).uniq { |item| item.comment_id }.sort_by{|comment|  comment.comment_created_at}
			@post_objs.unshift({post: post, comments: comments, time: condensed_time_ago(post.post_created_at), curr_member: (post.member_id == @curr_member.id)})
		end
		gon.posts = @posts
		@post_objs = @post_objs.reverse	
		gon.post_objs = @post_objs
	end






	def new
		curr_members =  Assignment.joins(:role).joins(:member).select("roles.name as role_name, members.*").where("members.user_id" => current_user.id).sort_by{|e| e.season_id}.reverse!
		@curr_member = curr_members.first

		@team_id = params[:team_id]

		## all non_default collectable stats that don't belong to a team,, default_stat: false, collectable: true
		@non_default_collectable_belongs = TeamStat.joins(:stat_list).select("stat_lists.*, team_stats.*").where("stat_lists.default_stat" => false, "stat_lists.collectable" => true, "team_stats.season_id" => params[:season_id]).sort_by{|e| e.stat_list_id}
		non_default_collectable =  StatList.where(default_stat: false, collectable: true)
		@non_default_collectable_add = []
		non_default_collectable.each do |stat| 
			add_stat = @non_default_collectable_belongs.none?{|s| s.stat_list_id == stat.id}
			if add_stat 
				@non_default_collectable_add.push(stat)
			end
		end

		@non_default_advanced_belongs = TeamStat.joins(:stat_list).select("stat_lists.*, team_stats.*").where("stat_lists.default_stat" => false, "stat_lists.advanced" => true, "stat_lists.team_stat" => false, "team_stats.season_id" => params[:season_id]).sort_by{|e| e.stat_list_id}
		non_default_advanced = StatList.where(advanced: true, team_stat: false, default_stat: false, hidden: false)
		@non_default_advanced_add = []
		non_default_advanced.each do |stat|
			add_stat = @non_default_advanced_belongs.none?{|s| s.stat_list_id == stat.id}
			if add_stat
				@non_default_advanced_add.push(stat)
			end
		end

		@non_default_team_advanced_belongs = TeamStat.joins(:stat_list).select("stat_lists.*, team_stats.*").where("stat_lists.default_stat" => false, "stat_lists.advanced" => true, "stat_lists.team_stat" => true, "team_stats.season_id" => params[:season_id]).sort_by{|e| e.stat_list_id}
		
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

	def create
		puts "SEASON ID: "
		puts params[:season_id]
		puts params[:id]
		Seasons::OldMemberPermissionsService.new({season_id: params[:season_id]}).call

		season = Seasons::CreateSeasonService.new({
			team_id: params[:team_id],
			team_name: params[:team_name],
			num_periods: params[:period_type],
			period_length: params[:period_length],
			primary_color: params[:primary_color],
			secondary_color: params[:secondary_color],
			multiple_year_bool: params[:multiple_year_bool],
			recurr_members: params[:recurr_members],
			new_members: params[:new_members],
			team_stats: params[:team_stats],
			current_user: current_user,
			old_season: params[:season_id]
		}).call



		# season = Season.create({
		# 	team_id: params[:team_id],
		# 	year1: Date.current.year,
		# 	year2: year2,
		# 	team_name: params[:team_name],
		# 	num_periods: params[:period_type],
		# 	period_length: params[:period_length],
		# 	primary_color: params[:primary_color],
		# 	secondary_color: params[:secondary_color],
		# 	dirty_stats: false,
		# 	multiple_years_flag: params[:multiple_year_bool],
		# })

		# same_name_seasons = Season.where(team_name: params[:team_name])

		

		# counter = 0
		# same_name_seasons.each do |s|
		# 	counter+=1
		# end

		# if counter > 1
		# 	username = params[:team_name] + counter.to_s
		# else
		# 	username = params[:team_name]
		# end

		# season.update(username: username)

		# Seasons::RecurringMembersService.new({
		# 	members: params[:recurr_members],
		# 	team_id: params[:team_id],
		# 	season_id: season.id
		# }).call


		# Teams::CreateTeamMembersService.new({
		# 	members: params[:new_members],
		# 	team_id: params[:team_id],
		# 	season_id: season.id
		# }).call

		# admin = Member.create({
		# 	nickname: "Coach " + current_user.first_name,
		# 	user_id: current_user.id,
		# 	permissions: {"plays_view" => true, "plays_edit" => true, "schedule_view" => true, "schedule_edit" => true, "stats_view" => true, "stats_edit" => true, "settings_view" => true, "settings_edit" => true },
		# 	is_admin: true,
		# 	season_id: season.id
		# })

		# Assignment.create({
		# 	member_id: admin.id,
		# 	role_id: 2
		# })


		# Teams::TeamStatService.new({
		# 	team_stats: params[:team_stats],
		# 	team_id: params[:team_id],
		# 	season_id: season.id
		# }).call

		redirect_to team_season_path(params[:team_id], season.id)
	end

	def join
		@season_id = params[:season_id]
		@team_id = params[:team_id]
		@member_id = params[:member_id]
		@season = Season.find_by_id(params[:season_id])


		gon.season_id = @season_id
		gon.team_id = @team_id
		gon.member_id = @member_id
	end

	def join_season
		@join_member_hash = params[:member_hash]
		@members = Member.where(season_id: params[:season_id])
		render_bool = true
		@members.each do |member|
			member_hash = Digest::SHA2.new << member.id.to_s + member.nickname
			if @join_member_hash == member_hash.to_s
				if member.user_id.nil?
					member.update(user_id: current_user.id)
					redirect_to team_season_path(params[:team_id], params[:season_id])
					render_bool = false
				end
			end
		end
		if render_bool
			render :json => {already_joined: true}
		end
		
	end

	def join_season_alt
		@join_password = params[:password]
		season = Season.where(username: params[:username]).take
		found_member = false
		already_joined = false
		if !season.nil? 
			@members = Member.where(season_id: season.id)
			@members.each do |member|
				member_hash = Digest::SHA2.new << member.id.to_s + member.nickname
				if @join_password == member_hash.to_s
					if member.user_id.nil?
						member.update(user_id: current_user.id)
						found_member = true
					else
						already_joined = true
					end
				end
			end
			if found_member
				redirect_to team_season_path(season.team_id, season.id)
			else
				if already_joined
					render :json => {message: "*It appears someone already joined using this username and password"}
				else
					render :json => {message: "*Username or password incorrect"}
				end
			end
		else
			render :json => {message: "*Username or password incorrect"}
		end
		
	end

	def destroy
		admin_permiss = current_user.admin 
		team = Team.find_by_id(params[:team_id])
		team_owner = team.user_id
		if(admin_permiss || current_user.id == team_owner)
			DeleteSeasonService.new({season_id: params[:id]}).call
			redirect_to admin_path
		end


	end

	private

	def convert_time_readable(time)
		substring = time.strftime("%I:%M%p")
		return substring
	end

	def condensed_time_ago(time)
		time_ago = time_ago_in_words(time)
		split_time = time_ago.split
		if split_time[0] == "about"
			condensed_time = split_time[1].to_s + split_time[2][0]
		elsif split_time[0] == "less"
			if split_time[2] == "a"
				split_time[2] = 1
			end
			condensed_time = split_time[2].to_s + split_time[3][0]
		else
			condensed_time = split_time[0].to_s + split_time[1][0]
		end
		return condensed_time
	end

	def day_of_week(day_int)
		case day_int
		when 0
			return "Sunday"
		when 1
			return "Monday"
		when 2
			return "Tuesday"
		when 3
			return "Wednesday"
		when 4
			return "Thursday"
		when 5
			return "Friday"
		when 6
			return "Saturday"
		end
	end

	def month_string(month_int)
		case month_int
		when 1
			return "January"
		when 2
			return "February"
		when 3
			return "March"
		when 4
			return "April"
		when 5
			return "May"
		when 6
			return "June"
		when 7
			return "July"
		when 8
			return "August"
		when 9
			return "September"
		when 10
			return "October"
		when 11
			return "Novemeber"
		when 12
			return "December"
		end
	end

	def get_post_type_object(post)
		case post.post_type_type
		when "Play"
			play = Play.find_by_id(post.post_type_id)
			progressions = Progression.where(:play_id => play.id).sort_by{|e| e.index}
			return progressions
		when "Game"
			return Game.find_by_id(post.post_type_id)
		end
	end

	def verify_member
		if params[:season_id].nil?
			curr_member = Member.where("members.user_id" => current_user.id, "members.season_id" => params[:id]).take
			if curr_member.nil? && !current_user.admin
				redirect_to root_path
			end
		else
			curr_member = Member.where("members.user_id" => current_user.id, "members.season_id" => params[:season_id]).take
			if curr_member.nil? && !current_user.admin
				redirect_to root_path
			end
		end
	end

	def verify_team_paid
		if params[:season_id].nil?
			curr_member = Member.where("members.user_id" => current_user.id, "members.season_id" => params[:id]).take
			season = Season.find_by_id(params[:id])
			team = Team.find_by_id(season.team_id)
			if !team.paid
				redirect_to no_access_path
			end
		else
			curr_member = Member.where("members.user_id" => current_user.id, "members.season_id" => params[:season_id]).take
			season = Season.find_by_id(params[:season_id])
			team = Team.find_by_id(season.team_id)
			if !team.paid
				redirect_to no_access_path
			end
		end
	end
end