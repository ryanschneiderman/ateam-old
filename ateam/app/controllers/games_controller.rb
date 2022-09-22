require 'json'

class GamesController < ApplicationController
	before_action :verify_team_paid, :authenticate_member, :verify_member
	def index
		@team_id = params[:team_id]
		@season_id = params[:season_id]
		gon.team_id = @team_id
		gon.season_id = @season_id
		@season = Season.find_by_id(params[:season_id])
		@team = Team.find_by_id(params[:team_id])

		@curr_member =  Member.where(user_id: current_user.id, season_id: params[:season_id]).take

		@games = Game.joins(:stat_totals).select("games.*, stat_totals.value").where("games.season_id" => params[:season_id], "stat_totals.stat_list_id" => 15)

		@game_events = ScheduleEvent.joins(game: :stat_totals).select("games.id as game_id, games.opponent_id as opponent_id, games.played as played, stat_totals.value as value, stat_totals.is_opponent as is_opponent, schedule_events.*").where("games.season_id" => params[:season_id], "stat_totals.stat_list_id" => 15)
		non_played_events = ScheduleEvent.joins(:game).select("games.id as game_id, games.opponent_id as opponent_id, games.played as played, schedule_events.*").where("games.season_id" => params[:season_id], "games.played" => false)
		game_events = []
		@game_events.group_by(&:game_id).each do |game_id, stats|
			game_events.push({game_id: game_id, stats: stats, date: stats[0].date, time: stats[0].time, place: stats[0].place, name: stats[0].name, played: stats[0].played, opponent_id: stats[0].opponent_id})
		end
		game_events.concat non_played_events
		gon.game_events = game_events
		@practice_events = ScheduleEvent.joins(:practice).select("practices.id as practice_id, practices.is_scrimmage as is_scrimmage, schedule_events.*").where("schedule_events.season_id" => params[:season_id])
		gon.practice_events = @practice_events
		@schedule_events = ScheduleEvent.where("schedule_events.season_id" => @season_id)
		gon.opponents = Opponent.where(team_id: @team_id)
		
	end 
	
	def new
		@game = Game.new
		@team_id = params[:team_id]
	end

	def update 
		team_id = params[:team_id]
		date = params[:date]
		time = params[:time]
		place = params[:location]
		game_id = params[:id]
		season_id = params[:season_id]

		is_new_opponent = params[:is_new_opponent]

		member = Member.where(user_id: current_user.id, season_id: params[:season_id]).take

		if is_new_opponent == "true"
			opponent = Opponent.new(name: params[:opponent], team_id: team_id)
			opponent.save!
		else
			opponent = Opponent.find_by_id(params[:opponent])
		end

		game = Game.find_by_id(game_id)
		schedule_event = ScheduleEvent.find_by_id(game.schedule_event_id)

		schedule_event.update(
			date: date,
			time: time,
			place: place,
			name: opponent.name,
			season_id: season_id,
		)

		game.update( opponent_id: opponent.id)

		redirect_to team_season_games_path(team_id, season_id)

		notif = Notification.create(
			content: "Game updated against " + opponent.name + " @ " + place,
			notif_type_type: "Game",
			notif_type_id: game.id,
			notif_kind: "created",
			season_id: season_id
		)

		members = Member.where(season_id: params[:season_id])
		members.each do |team_member|
			if member.present? && team_member.id != member.id
				MemberNotif.create(
					member_id: team_member.id,
					notification_id: notif.id,
					viewed: false,
					read: false,
				)
			else
				MemberNotif.create(
					member_id: team_member.id,
					notification_id: notif.id,
					viewed: true,
					read: true,
				)
			end
		end
	end

	def create

		team_id = params[:team_id]
		date = params[:date]
		time = params[:time]
		place = params[:location]
		season_id = params[:season_id]
		is_new_opponent = params[:is_new_opponent]

		member = Member.where(user_id: current_user.id, season_id: params[:season_id]).take

		if is_new_opponent == "true"
			puts "IN NEW OPPONENT"
			opponent = Opponent.new(name: params[:opponent], team_id: team_id)
			opponent.save!
		else
			puts "IN EXISTING OPPONENT"
			opponent = Opponent.find_by_id(params[:opponent])
		end

		schedule_event = ScheduleEvent.create(
			date: date,
			time: time,
			place: place,
			name: opponent.name,
			season_id: season_id,
		)

		game = Game.new(played: false, schedule_event_id: schedule_event.id, season_id: params[:season_id], opponent_id: opponent.id)
		game.save!

		redirect_to team_season_games_path(team_id, season_id)

		notif = Notification.create(
			content: "Game scheduled against " + opponent.name + " @ " + place,
			notif_type_type: "Game",
			notif_type_id: game.id,
			notif_kind: "created",
			season_id: params[:season_id]
		)

		members = Member.where(season_id: params[:season_id])
		members.each do |team_member|
			if member.present? && team_member.id != member.id
				MemberNotif.create(
					member_id: team_member.id,
					notification_id: notif.id,
					viewed: false,
					read: false,
				)
			else
				MemberNotif.create(
					member_id: team_member.id,
					notification_id: notif.id,
					viewed: true,
					read: true,
				)
			end
		end

	end

	def show
		team_id = params[:team_id]
		@team = Team.find_by_id(params[:team_id])
		@game = Game.find_by_id(params[:id])
		@played = @game.played

		@team_id = team_id
		season_id = params[:season_id]
		@season = Season.find_by_id(season_id)
		@team_name = @season.team_name

		@curr_member =   Member.where(user_id: current_user.id, season_id: params[:season_id],).take

		if !@played && @games_write
			redirect_to game_mode_path(@team_id, season_id, params[:id])
		elsif !@played && !@games_write
			redirect_to game_preview_path(@team_id, season_id, params[:id])
		elsif @played
			@per_minutes = @season.num_periods * @season.period_length * 3 / 4

			@players = Member.where(season_id: params[:season_id], is_player: true)

			@opponent = Opponent.find_by_id(@game.opponent_id)
			@opponent_name = @opponent.name

			@stat_table_columns = Stats::BasicStatService.new({
				season_id: params[:season_id]
			}).call

			@adv_stat_table_columns = Stats::Advanced::AdvancedStatListService.new({
				season_id: params[:season_id]
			}).call

			@team_adv_stat_table_columns = Stats::Advanced::TeamAdvancedStatListService.new({
				season_id: params[:season_id]
			}).call

			
			@player_stats = []
			player_stats_ungrouped = Stat.joins(:stat_list, :member).select("stat_lists.stat as stat, members.nickname as nickname, stat_lists.display_priority as display_priority, stats.*").where("stats.season_id" => params[:season_id], "stats.game_id" => @game.id).sort_by{|e| [e.member_id, e.stat_list_id]}
			
			player_stats_ungrouped.group_by(&:member_id).each do |member_id, stats|
				@player_stats.push({member_id: member_id, stats: stats, nickname: stats[0].nickname, games_played: 1})
			end

			@team_stats = StatTotal.select("*").joins(:stat_list).where(game_id: @game.id, is_opponent: false, season_id: params[:season_id])

			@opponent_stats = StatTotal.select("*").joins(:stat_list).where(game_id: @game.id, is_opponent: true, season_id: params[:season_id])

			@shot_chart_data = []
			shot_chart_data_ungrouped = StatGranule.joins(:member).select("stat_granules.*, members.*").where("stat_granules.game_id" => @game.id, "stat_granules.stat_list_id"=> [1,2])

			shot_chart_data_ungrouped.group_by(&:member_id).each do |member_id, data|
				@shot_chart_data.push({member_id: member_id, data: data, name: data[0].nickname})
			end

			opponent_shot_chart_data = OpponentGranule.where("opponent_granules.game_id" => @game.id, "opponent_granules.stat_list_id"=> [1,2])

			#@shot_chart_data = StatGranule.select("*").joins(:member).where(game_id: @game.id).where("stat_granules.season_id"=> params[:season_id], "stat_granules.stat_list_id"=> [1,2])

			@advanced_stats = []
			advanced_stats_ungrouped = AdvancedStat.joins(:stat_list, :member).select("stat_lists.stat as stat, members.nickname as nickname, stat_lists.stat_description as stat_description, stat_lists.display_priority as display_priority, advanced_stats.*").where("advanced_stats.season_id" => params[:season_id]).sort_by{|e| [e.member_id, e.stat_list_id]}
			advanced_stats_ungrouped.group_by(&:member_id).each do |member_id, stats|
				@advanced_stats.push({member_id: member_id, stats: stats, nickname: stats[0].nickname})
			end

			#@advanced_stats = AdvancedStat.select("*").joins(:stat_list).where(game_id: @game.id, season_id: params[:season_id]).sort_by{|e| [e.member_id, e.stat_list_id]}


			@team_advanced_stats = TeamAdvancedStat.select("*").joins(:stat_list).select("*").where(game_id: @game.id, season_id: params[:season_id])

			@players = Stats::SortStatService.new({
				game_id: @game.id,
				season_id: params[:season_id]
			}).call

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
		end

	end

	def game_preview
		@team = Team.find_by_id(params[:team_id])
		@season = Season.find_by_id(params[:season_id])
		@team_id = params[:team_id]
		@season_id = params[:season_id]
		game = Game.find_by_id(params[:id])
		@opponent = Opponent.find_by_id(game.opponent_id)
		@schedule_event = ScheduleEvent.find_by_id(game.schedule_event_id)
	end

	

	def game_mode
		@game_id = params[:id]
		game = Game.find_by_id(@game_id)
		@game_state = game.game_state
		team_id = params[:team_id]
		@team = Team.find_by_id(team_id)
		@season = Season.find_by_id(params[:season_id])
		gon.game_state = @game_state.to_json.html_safe
		gon.game_id = @game_id
		gon.team_id = team_id
		gon.team_name = @season.team_name
		@team_name = @season.team_name
		
		gon.season_id = params[:season_id]

		curr_member =  Member.where(user_id: current_user.id, season_id: params[:season_id]).take
		if curr_member.present?
			gon.current_member_nickname = curr_member.nickname
		end

		gon.current_user = current_user


		@players = Member.joins(:assignments).where(season_id: params[:season_id], is_player: true)
		gon.players = @players

		@opponent = Opponent.find_by_id(game.opponent_id)
		@opponent_name = @opponent.name
		@opponent_id = @opponent.id
		gon.opponent_id = @opponent_id
		gon.opponent_name = @opponent_name

		gon.opponent = @opponent
		team_stats = TeamStat.where(season_id: params[:season_id])


		@per_minutes = @season.period_length 
		gon.num_periods = @season.num_periods
		gon.period_length = @season.period_length


		collection_stat_list = []
		@basic_stats = []
		collection_team_stats = TeamStat.where(season_id: params[:season_id]).joins(:stat_list).where('stat_lists.collectable' => true);
		basic_team_stats = TeamStat.where(season_id: params[:season_id]).joins(:stat_list).where('stat_lists.advanced' => false, 'stat_lists.team_stat' =>false, 'stat_lists.is_percent' => false);
		collection_team_stats.each do |stat|
			collection_stat_list.push(StatList.find_by_id(stat.stat_list_id))
		end

		@collection_stats = Stats::CollectableStatsService.new({
			stats: collection_stat_list
		}).call

		gon.collection_stats = @collection_stats

		basic_team_stats.each do |stat|
			@basic_stats.push(StatList.find_by_id(stat.stat_list_id))
		end
		gon.basic_stats = @basic_stats

		## return an array which has the fields that we will want to display in the stat table, and their corresponding ordering number.
		@stat_table_columns = Stats::StatTableColumnsService.new({
			stats: @basic_stats,
			is_advanced: false
		}).call
		gon.stat_table_columns = @stat_table_columns.reverse!
	end

	def game_state_update
		game = Game.find_by_id(params[:id])
	  	game.update_attributes(:game_state => params[:game_state])
	  	game.save
	end


	## service
	def game_mode_submit
		start = Time.now
		player_stats = params[:player_stats]
		team_stats = params[:team_stats]
		opponent_stats = params[:opponent_stats]
		lineup_stats = params[:lineup_stats]
		game_id = params[:id]
		@team_id = params[:team_id]

		season_id = params[:season_id]
		season = Season.find_by_id(season_id)


		team = Team.find_by_id(@team_id)
		game = Game.find_by_id(game_id)
		schedule_event = ScheduleEvent.find_by_id(game.schedule_event_id)
		opponent = Opponent.find_by_id(game.opponent_id)
		member = Member.where(user_id: current_user.id, season_id: season_id).take


		if game.played
			Stats::RollbackGameService.new({game_id: game_id, submit: true, team_id: @team_id, season_id: season_id}).call
		end

		SubmitGameModeService.new({
			player_stats: player_stats,
			team_stats: team_stats,
			opponent_stats: opponent_stats,
			lineup_stats: lineup_stats,
			game_id: game_id,
			team_id: @team_id,
			period_length: season.period_length,
			num_periods: season.num_periods,
			season_id: season_id
		}).call

		game.update(played: true)
		season.update(dirty_stats: true)

		notif = Notification.create(
			content: "Stats added for game vs. " + opponent.name + " @ " + schedule_event.place,
			notif_type_type: "Game",
			notif_type_id: game.id,
			notif_kind: "added",
			season_id: params[:season_id]
		)

		members = Member.where(season_id: season_id)
		members.each do |team_member|
			if member.present? && team_member.id != member.id
				MemberNotif.create(
					member_id: team_member.id,
					notification_id: notif.id,
					viewed: false,
					read: false,
				)
			else
				MemberNotif.create(
					member_id: team_member.id,
					notification_id: notif.id,
					viewed: true,
					read: true,
				)
			end
		end

		stat_ranking(@team_id, season_id)

		# code to time
		finish = Time.now
		# puts "**************************************** EXECUTE TIME ****************************************"
		# puts finish-start
		redirect_to team_season_game_path(@team_id, season_id, game_id)
	end
	def practice_mode
		@team_id = params[:team_id]
		@team = Team.find_by_id(@team_id)

		@players = Member.where(season_id: params[:season_id], is_player: true)

		gon.season_id = params[:season_id]
		gon.team_id = @team_id

		@season = Season.find_by_id(params[:season_id])

		collection_stat_list = []
		@basic_stats = []
		collection_team_stats = TeamStat.where(season_id: params[:season_id]).joins(:stat_list).where('stat_lists.collectable' => true);
		basic_team_stats = TeamStat.where(season_id: params[:season_id]).joins(:stat_list).where('stat_lists.advanced' => false, 'stat_lists.team_stat' =>false, 'stat_lists.is_percent' => false);
		collection_team_stats.each do |stat|
			collection_stat_list.push(StatList.find_by_id(stat.stat_list_id))
		end

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
		gon.season_id = params[:season_id]
		gon.team_id = @team_id

		@season = Season.find_by_id(params[:season_id])
		@per_minutes = @season.num_periods * @season.period_length * 0.75

		

		@players = Member.where(season_id: params[:season_id], is_player: true)
		collection_stat_list = []
		@basic_stats = []
		collection_team_stats = TeamStat.where(season_id: params[:season_id]).joins(:stat_list).where('stat_lists.collectable' => true);
		basic_team_stats = TeamStat.where(season_id: params[:season_id]).joins(:stat_list).where('stat_lists.advanced' => false, 'stat_lists.team_stat' =>false, 'stat_lists.is_percent' => false);
		collection_team_stats.each do |stat|
			collection_stat_list.push(StatList.find_by_id(stat.stat_list_id))
		end

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
		today = Date.today
		season_id = params[:season_id]

		schedule_event = ScheduleEvent.create(
			date: today,
			season_id: season_id
		)

		practice = Practice.create(
			season_id: season_id,
			schedule_event_id: schedule_event.id,
			is_scrimmage: true,
		)


		SubmitPracticeModeService.new({
			player_stats: player_stats,
			team_stats: team_stats,
			opponent_stas: opponent_stats,
			practice_id: practice.id,
			season_id: params[:season_id]
		}).call

		redirect_to team_season_practice_path(team_id, season_id, practice.id)
	end

	def destroy
		game_id = params[:id]
		team_id = params[:team_id]
		season_id = params[:season_id]

		game = Game.find_by_id(game_id)
		if game.played
			Stats::RollbackGameService.new({game_id: game_id, submit: false, team_id: team_id, season_id: season_id}).call
			if Game.where(season_id: season_id, played: true).length > 0
				Stats::GameModeCallbackService.new({team_id: team_id, curr_season_id: season_id}).call
			end
		end
		schedule_event = ScheduleEvent.find_by_id(game.schedule_event_id)

		schedule_event.destroy

		game.destroy

		# notifs = Notification.where(notif_type_id: game_id)
		# notifs.each do |notif|
		# 	MemberNotif.where(notification_id: notif.id).destroy_all
		# end
		# notifs.destroy_all

		redirect_to team_season_games_path(team_id, season_id)


	end

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

	def stat_ranking(team_id, curr_season_id)
		season = Season.find_by_id(curr_season_id)
		if(season.dirty_stats)
			Stats::GameModeCallbackService.new({
				team_id: team_id,
				curr_season_id: curr_season_id
			}).call
			season.update(dirty_stats: false)
		end
	end
end
