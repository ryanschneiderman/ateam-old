require 'json'

class PracticesController < ApplicationController
	before_action :verify_team_paid, :authenticate_member, :verify_member
	def create
		team_id = params[:team_id]
		date = params[:date]
		time = params[:time]
		place = params[:location]
		season_id = params[:season_id]

		schedule_event = ScheduleEvent.create(
			date: date,
			time: time,
			place: place,
			season_id: season_id
		)

		practice = Practice.new(
			season_id: season_id,
			schedule_event_id: schedule_event.id,
			is_scrimmage: false,
			game_state: nil,
			played: false,
		)

		practice.validate!            
		practice.errors.full_messages 

		practice.save

		redirect_to team_season_games_path(team_id, season_id)
	end

	def show
		
		@team = Team.find_by_id(params[:team_id])
		@team_id = params[:team_id]
		@practice = Practice.find_by_id(params[:id])
		@practice_id = params[:id]
		@schedule_event = ScheduleEvent.find_by_id(@practice.schedule_event_id)
		@is_scrimmage = @practice.is_scrimmage
		@per_minutes = @team.minutes_p_q * 3
		@played = @practice.played

		gon.team_id = params[:team_id]
		gon.season_id = params[:season_id]

		@season = Season.find_by_id(params[:season_id])

		@curr_member =  Member.where(user_id: current_user.id, season_id: params[:season_id]).take
		

		if @is_scrimmage
			@page_title = "Scrimmage"
			@opponent_name = "Opponent"
			@team_name = season.name
		else
			@page_title = "Practice"
			@opponent_name = "Team 2"
			@team_name = "Team 1"
		end




		@players = Assignment.joins(:role).joins(:member).select("roles.name as name, members.*").where("members.team_id" => @team.id, "roles.id" => 1)

		@stat_table_columns = Stats::BasicStatService.new({
			team_id: params[:team_id]
		}).call

		@per_minutes = @team.minutes_p_q * 3

		


		@player_stats = PracticeStat.select("*").joins(:stat_list).select("*").joins(:member).where(practice_id: @practice.id).sort_by{|e| [e.member_id, e.stat_list_id]}

		@team_stats = PracticeStatTotal.select("*").joins(:stat_list).where(team_id: params[:team_id], practice_id: @practice.id, is_opponent: false)

		@opponent_stats = PracticeStatTotal.select("*").joins(:stat_list).where(team_id: params[:team_id], practice_id: @practice.id, is_opponent: true)

		@shot_chart_data = PracticeStatGranule.select("*").joins(:member).where(practice_id: @practice.id).where("stat_list_id IN (?)", [1,2])



		@players = Stats::SortPracticeStatService.new({
			practice_id: @practice.id
		}).call

		@team_stat_table_columns = Stats::BasicStatService.new({
			team_id: params[:team_id]
		}).call

		@team_stat_table_columns.delete_if{|h| h[:stat_name] == "Minutes"}
	end


	def show

		@team = Team.find_by_id(params[:team_id])
		@team_id = params[:team_id]
		@practice = Practice.find_by_id(params[:id])
		@practice_id = params[:id]
		@schedule_event = ScheduleEvent.find_by_id(@practice.schedule_event_id)
		@is_scrimmage = @practice.is_scrimmage


		season_id = params[:season_id]
		@season = Season.find_by_id(season_id)
		@team_name = @season.team_name

		@curr_member =   Member.where(user_id: current_user.id, season_id: params[:season_id],).take

		# if !@played && @games_write
		# 	redirect_to game_mode_path(@team_id, season_id, params[:id])
		# elsif !@played && !@games_write
		# 	redirect_to game_preview_path(@team_id, season_id, params[:id])
		# elsif @played
			@per_minutes = @season.num_periods * @season.period_length * 3 / 4

			@players = Member.where(season_id: params[:season_id], is_player: true)


			@stat_table_columns = Stats::BasicStatService.new({
				season_id: params[:season_id]
			}).call

			# @adv_stat_table_columns = Stats::Advanced::AdvancedStatListService.new({
			# 	season_id: params[:season_id]
			# }).call

			# @team_adv_stat_table_columns = Stats::Advanced::TeamAdvancedStatListService.new({
			# 	season_id: params[:season_id]
			# }).call

			
			player_stats = []
			player_stats_ungrouped = PracticeStat.joins(:stat_list, :member).select("stat_lists.stat as stat, members.nickname as nickname, stat_lists.display_priority as display_priority, practice_stats.*").where("practice_stats.season_id" => params[:season_id], "practice_stats.practice_id" => @practice.id).sort_by{|e| [e.member_id, e.stat_list_id]}
			# @player_stats = PracticeStat.select("*").joins(:stat_list).select("*").joins(:member).where(practice_id: @practice.id).sort_by{|e| [e.member_id, e.stat_list_id]}
			player_stats_ungrouped.group_by(&:member_id).each do |member_id, stats|
				@player_stats.push({member_id: member_id, stats: stats, nickname: stats[0].nickname, games_played: 1})
			end
			@team_stats = PracticeStatTotal.select("*").joins(:stat_list).where(season_id: params[:season_id], practice_id: @practice.id, is_opponent: false)

			@opponent_stats = PracticeStatTotal.select("*").joins(:stat_list).where(season_id: params[:season_id], practice_id: @practice.id, is_opponent: true)

			@shot_chart_data = []
			shot_chart_data_ungrouped = PracticeStatGranule.joins(:member).select("stat_granules.*, members.*").where("stat_granules.game_id" => @practice.id, "stat_granules.stat_list_id"=> [1,2])

			shot_chart_data_ungrouped.group_by(&:member_id).each do |member_id, data|
				@shot_chart_data.push({member_id: member_id, data: data, name: data[0].nickname})
			end

			# opponent_shot_chart_data = OpponentGranule.where("opponent_granules.game_id" => @game.id, "opponent_granules.stat_list_id"=> [1,2])

			#@shot_chart_data = StatGranule.select("*").joins(:member).where(game_id: @game.id).where("stat_granules.season_id"=> params[:season_id], "stat_granules.stat_list_id"=> [1,2])

			# @advanced_stats = []
			# advanced_stats_ungrouped = AdvancedStat.joins(:stat_list, :member).select("stat_lists.stat as stat, members.nickname as nickname, stat_lists.stat_description as stat_description, stat_lists.display_priority as display_priority, advanced_stats.*").where("advanced_stats.season_id" => params[:season_id]).sort_by{|e| [e.member_id, e.stat_list_id]}
			# advanced_stats_ungrouped.group_by(&:member_id).each do |member_id, stats|
			# 	@advanced_stats.push({member_id: member_id, stats: stats, nickname: stats[0].nickname})
			# end

			#@advanced_stats = AdvancedStat.select("*").joins(:stat_list).where(game_id: @game.id, season_id: params[:season_id]).sort_by{|e| [e.member_id, e.stat_list_id]}


			# @team_advanced_stats = TeamAdvancedStat.select("*").joins(:stat_list).select("*").where(game_id: @game.id, season_id: params[:season_id])
			@players = Stats::SortPracticeStatService.new({
				practice_id: @practice.id,
				season_id: params[:season_id]
			}).call

			# @players = Stats::SortStatService.new({
			# 	game_id: @game.id,
			# 	season_id: params[:season_id]
			# }).call

			@team_stat_table_columns = Stats::BasicStatService.new({
				season_id: params[:season_id]
			}).call

			@team_stat_table_columns.delete_if{|h| h[:stat_name] == "Minutes"}

			gon.season_id = params[:season_id]
			gon.team_name = @team_name
			gon.team_id = team_id
			gon.num_players = @players.length
			gon.minutes_factor = @per_minutes
			gon.stat_table_columns = @stat_table_columns
			gon.adv_stat_table_columns = @adv_stat_table_columns
			gon.team_adv_stat_table_columns = @team_adv_stat_table_columns
			gon.player_stats = @player_stats
			gon.advanced_stats = @advanced_stats
			gon.team_stats= @team_stats
			gon.opponent_stats = @opponent_stats
			gon.team_advanced_stats = @team_advanced_stats
			gon.shot_chart_data = @shot_chart_data
			gon.opponent_shot_chart_data = opponent_shot_chart_data
			gon.opponent_name = @opponent_name
		# end

	end

	def practice_mode
		@team_id = params[:team_id]
		@team = Team.find_by_id(@team_id)
		@practice_id = params[:id]
		@players = Assignment.joins(:role).joins(:member).select("roles.name as name, members.*").where("members.team_id" => @team_id, "roles.id" => 1)
		collection_stat_list = []
		@basic_stats = []
		collection_team_stats = TeamStat.where(team_id: params[:team_id]).joins(:stat_list).where('stat_lists.collectable' => true);
		basic_team_stats = TeamStat.where(team_id: params[:team_id]).joins(:stat_list).where('stat_lists.advanced' => false, 'stat_lists.team_stat' =>false, 'stat_lists.is_percent' => false);
		collection_team_stats.each do |stat|
			collection_stat_list.push(StatList.find_by_id(stat.stat_list_id))
		end
		gon.team_id = params[:team_id]
		gon.season_id = params[:season_id]
		@season = Season.find_by_id(params[:season_id])

		@collection_stats = Stats::CollectableStatsService.new({
			stats: collection_stat_list
		}).call

		basic_team_stats.each do |stat|
			@basic_stats.push(StatList.find_by_id(stat.stat_list_id))
		end

		## return an array which has the fields that we will want to display in the stat table, and their corresponding ordering number.
		@stat_table_columns = Stats::StatTableColumnsService.new({
			stats: @basic_stats,
			is_advanced: false
		}).call
	end

	def scrimmage_mode
		@team_id = params[:team_id]
		@team = Team.find_by_id(@team_id)
		@minutes_p_q = @team.minutes_p_q
		@players = Assignment.joins(:role).joins(:member).select("roles.name as name, members.*").where("members.team_id" => @team_id, "roles.id" => 1)
		collection_stat_list = []
		@basic_stats = []
		collection_team_stats = TeamStat.where(team_id: params[:team_id]).joins(:stat_list).where('stat_lists.collectable' => true);
		basic_team_stats = TeamStat.where(team_id: params[:team_id]).joins(:stat_list).where('stat_lists.advanced' => false, 'stat_lists.team_stat' =>false, 'stat_lists.is_percent' => false);
		collection_team_stats.each do |stat|
			collection_stat_list.push(StatList.find_by_id(stat.stat_list_id))
		end
		gon.team_id = params[:team_id]
		gon.season_id = params[:season_id]
		@season = Season.find_by_id(params[:season_id])

		@collection_stats = Stats::CollectableStatsService.new({
			stats: collection_stat_list
		}).call

		basic_team_stats.each do |stat|
			@basic_stats.push(StatList.find_by_id(stat.stat_list_id))
		end

		## return an array which has the fields that we will want to display in the stat table, and their corresponding ordering number.
		@stat_table_columns = Stats::StatTableColumnsService.new({
			stats: @basic_stats,
			is_advanced: false
		}).call
	end

	def scrimmage_mode_submit
		player_stats = params[:player_stats]
		team_stats = params[:team_stats]
		opponent_stats = params[:opponent_stats]
		team_id = params[:team_id]
		is_scrimmage = params[:is_scrimmage]
		practice = Practice.find_by_id(params[:id])

		SubmitPracticeModeService.new({
			player_stats: player_stats,
			team_stats: team_stats,
			opponent_stats: opponent_stats,
			practice_id: practice.id,
			team_id: team_id
		}).call

		practice.played = true;
		practice.save

		redirect_to team_practice_path(team_id, practice.id)
	end

	def update 
		team_id = params[:team_id]
		date = params[:date]
		time = params[:time]
		place = params[:location]
		practice_id = params[:id]
		season_id = params[:season_id]

		member = Member.where(user_id: current_user.id, season_id: params[:season_id]).take

		practice = Practice.find_by_id(practice_id)
		schedule_event = ScheduleEvent.find_by_id(practice.schedule_event_id)

		schedule_event.update(
			date: date,
			time: time,
			place: place,
			season_id: season_id,
		)


		redirect_to team_season_games_path(team_id, season_id)

		# notif = Notification.create(
		# 	content: "Practice updated against " + opponent.name + " @ " + place,
		# 	notif_type_type: "Game",
		# 	notif_type_id: practice.id,
		# 	notif_kind: "created",
		# 	season_id: season_id
		# )

		# members = Member.where(season_id: params[:season_id])
		# members.each do |team_member|
		# 	if team_member.id != member.id
		# 		MemberNotif.create(
		# 			member_id: team_member.id,
		# 			notification_id: notif.id,
		# 			viewed: false,
		# 			read: false,
		# 		)
		# 	else
		# 		MemberNotif.create(
		# 			member_id: team_member.id,
		# 			notification_id: notif.id,
		# 			viewed: true,
		# 			read: true,
		# 		)
		# 	end
		# end
	end

	def destroy
		practice_id = params[:id]
		team_id = params[:team_id]
		season_id = params[:season_id]

		practice = Practice.find_by_id(practice_id)


		# if game.played
		# 	Stats::RollbackGameService.new({game_id: game_id, submit: false, team_id: team_id, season_id: season_id}).call
		# end
		schedule_event = ScheduleEvent.find_by_id(practice.schedule_event_id)

		schedule_event.destroy

		practice.destroy

		# notifs = Notification.where(notif_type_id: game_id)
		# notifs.each do |notif|
		# 	MemberNotif.where(notification_id: notif.id).destroy_all
		# end
		# notifs.destroy_all

		redirect_to team_season_games_path(team_id, season_id)
	end
=begin
	def practice_mode_submit
		player_stats = params[:player_stats]
		team_stats = params[:team_stats]
		opponent_stats = params[:opponent_stats]
		team_id = params[:team_id]
		today = Date.today

		schedule_event = ScheduleEvent.create(
			date: today,
			team_id: team_id,
		)

		practice = Practice.new(
			team_id: team_id,
			schedule_event_id: schedule_event.id,
			is_scrimmage: false,
			game_state: nil
		)

		practice.validate!            # => ["cannot be nil"]
		practice.errors.full_messages # => ["name cannot be nil"]

		practice.save


		SubmitPracticeModeService.new({
			player_stats: player_stats,
			team_stats: team_stats,
			opponent_stats: opponent_stats,
			practice_id: practice.id,
			team_id: team_id
		}).call

		redirect_to team_practice_path(team_id, practice.id)
	end
=end

private

	def verify_team_paid
		season = Season.find_by_id(params[:season_id])
		team = Team.find_by_id(season.team_id)
		if !team.paid
			redirect_to no_access_path
		end
	end

	def verify_member
		curr_member = Member.where("members.user_id" => current_user.id, "members.season_id" => params[:season_id]).take
		if curr_member.nil? && !current_user.admin
			redirect_to root_path
		end
	end

	def authenticate_member
		member = Member.where(user_id: current_user.id, season_id: params[:season_id]).take
		if !member && current_user.admin 
			@games_write = true
			@games_read = true
			@stats_read = true
			@stats_write = true
		else
			@games_write = member.permissions["schedule_edit"]
			@games_read = member.permissions["schedule_view"]
			@stats_read = member.permissions["stats_view"]
			@stats_write = member.permissions["stats_edit"]
		end

		gon.games_write = @games_write
		gon.games_read = @games_read
		gon.schedule_edit_permission = @games_write
		gon.stats_read = @stats_read
		gon.stats_write = @stats_write
	end

end
