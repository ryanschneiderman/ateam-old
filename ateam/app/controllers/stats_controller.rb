class StatsController < ApplicationController
	before_action :verify_team_paid, :authenticate_member, :verify_member
	skip_before_action :verify_team_paid, :authenticate_member, :verify_member,:authenticate_user!, only: [:trend_data, :shot_chart_data, :load_more_lineups, :player_profile]
	def index
		@team_id = params[:team_id]
		@season_id = params[:season_id]
		@team = Team.find_by_id(@team_id)
		
		#@team_name = @team.name
		
		@season = Season.find_by_id(@season_id)
		@team_name = @season.team_name
		
		@per_minutes = @season.num_periods * @season.period_length * 3 / 4


		@players = Member.where(is_player: true, season_id: params[:season_id])

		@num_games = Game.where(played: true, season_id: params[:season_id]).count

		@opponent_name = "Opponents"



		@stat_table_columns = Stats::BasicStatService.new({
			season_id: params[:season_id]
		}).call
		@stat_table_columns = @stat_table_columns.sort_by{|e| [e[:stat_kind], e[:display_priority]]}


		@adv_stat_table_columns = Stats::Advanced::AdvancedStatListService.new({
			season_id: params[:season_id]
		}).call


		@team_adv_stat_table_columns = Stats::Advanced::TeamAdvancedStatListService.new({
			season_id: params[:season_id]
		}).call

		## player stats
		@player_stats = []

		player_stats_ungrouped = SeasonStat.joins(:stat_list, :member).select("members.games_played as games_played, members.season_minutes as season_minutes, stat_lists.stat as stat, members.nickname as nickname, stat_lists.display_priority as display_priority, season_stats.*").where("season_stats.season_id" => params[:season_id]).sort_by{|e| [e.member_id, e.stat_list_id]}
		player_stats_ungrouped.group_by(&:member_id).each do |member_id, stats|
			@player_stats.push({member_id: member_id, stats: stats, nickname: stats[0].nickname, games_played: stats[0].games_played, minutes: stats[0].season_minutes})
		end

		@advanced_stats = []
		advanced_stats_ungrouped = SeasonAdvancedStat.joins(:stat_list, :member).select("members.games_played as games_played, members.season_minutes as season_minutes, stat_lists.stat as stat, members.nickname as nickname, stat_lists.stat_description as stat_description, stat_lists.display_priority as display_priority, season_advanced_stats.*").where("season_advanced_stats.season_id" => params[:season_id]).sort_by{|e| [e.member_id, e.stat_list_id]}
		advanced_stats_ungrouped.group_by(&:member_id).each do |member_id, stats|
			@advanced_stats.push({member_id: member_id, stats: stats, nickname: stats[0].nickname, games_played: stats[0].games_played, minutes: stats[0].season_minutes})
		end

		@team_stats = TeamSeasonStat.select("*").joins(:stat_list).where(is_opponent: false, season_id: params[:season_id])

		@opponent_stats = TeamSeasonStat.select("*").joins(:stat_list).where(is_opponent: true, season_id: params[:season_id])

		@team_advanced_stats = SeasonTeamAdvStat.select("*").joins(:stat_list).where(season_id: params[:season_id])

		opponent_shot_chart_data = OpponentGranule.joins(:opponent).select("opponent_granules.*").where("opponent_granules.season_id" => params[:season_id], "opponent_granules.stat_list_id"=> [1,2])


		@lineups = Lineup.where(season_id: @season_id)
		
		@members = Member.where( is_player: true, season_id: params[:season_id])

		gon.lineup_objs = StatsIndex::LineupStatsService.new({team_id: @team_id, season_id: params[:season_id], sorting_stat: 16, page: 1}).call

		@team_points = StatTotal.joins([:stat_list, {:game => :opponent}, {:game => :schedule_event}]).select("schedule_events.date as date, stat_lists.stat as stat, opponents.name as opponent_name, stat_totals.*").where("stat_lists.team_stat" => false, "stat_totals.is_opponent" => false,  "stat_lists.rankable" => true, "stat_lists.id" => 15, "stat_totals.season_id" => params[:season_id]).sort_by{|e| [e.stat_list_id, e.date]}
		gon.team_points = @team_points;

		#@stat_totals = StatTotal.joins(:stat_list).joins(:game => :schedule_event).select("schedule_events.date as date, stat_lists.stat as stat, stat_totals.*").where("stat_lists.team_stat" => false, "stat_totals.team_id" => @team.id, "stat_totals.is_opponent" => false, "stat_lists.rankable" => true).sort_by{|e| [e.stat_list_id, e.date]}
		@trend_stat_lists = TeamStat.joins(:stat_list).select("stat_lists.stat as stat, team_stats.*").where("team_stats.season_id" => params[:season_id], "stat_lists.team_stat" => false, "stat_lists.rankable" => true, "stat_lists.advanced" => false).sort_by{|e| e.stat_list_id}


		@off_stat_lists = TeamStat.joins(:stat_list).select("stat_lists.stat as stat, team_stats.*").where("team_stats.season_id" => params[:season_id], "stat_lists.team_stat" => false, "stat_lists.rankable" => true, "stat_lists.advanced" => false, "stat_lists.stat_kind" => 1).sort_by{|e| e.stat_list_id}

		@def_stat_lists = TeamStat.joins(:stat_list).select("stat_lists.stat as stat, team_stats.*").where("team_stats.season_id" => params[:season_id], "stat_lists.team_stat" => false, "stat_lists.rankable" => true, "stat_lists.advanced" => false, "stat_lists.stat_kind" => 2).sort_by{|e| e.stat_list_id}

		gon.season_id = params[:season_id]
		gon.team_name = @team_name
		gon.team_id = @team_id
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
		gon.off_stat_lists = @off_stat_lists
		gon.def_stat_lists = @def_stat_lists
	end 


	def load_more_lineups
		page = params[:page]
		sorting_stat = params[:sorting_stat]
		lineup_objs = StatsIndex::LineupStatsService.new({team_id: params[:team_id], season_id: params[:season_id], sorting_stat: params[:sorting_stat], page: params[:page]}).call
		render :json => {lineup_objs: lineup_objs, reload: params[:reload]}
	end

	def shot_chart_data
		shot_chart_data = []
		#shot_chart_data = StatGranule.where("stat_granules.season_id" => params[:season_id], "stat_granules.stat_list_id"=> [1,2]).select(:metadata, :stat_list_id)
		shot_chart_data_ungrouped = StatGranule.joins(:member).select("stat_granules.*, members.*").where("stat_granules.season_id" => params[:season_id], "stat_granules.stat_list_id"=> [1,2])

		shot_chart_data_ungrouped.group_by(&:member_id).each do |member_id, data|
			shot_chart_data.push({member_id: member_id, data: data, name: data[0].nickname})
		end
		opponent_shot_chart_data = OpponentGranule.joins(:opponent).select("opponent_granules.*").where("opponent_granules.season_id" => params[:season_id], "opponent_granules.stat_list_id"=> [1,2])

		render :json => {shot_chart_data: shot_chart_data, opponent_shot_chart_data: opponent_shot_chart_data}
	end


	def trend_data
		season_id = params[:season_id]
		if params[:stat][:is_advanced] == "true"
			if params[:is_team] == "true"
				if params[:is_opponent] == "true"
					##puts "opponent advanced"
					stats = TeamAdvancedStat.joins([:stat_list, { game: :team }, {game: :opponent}, {:game => :schedule_event}]).select("schedule_events.date as date, stat_lists.stat as stat, opponents.name as opponent_name, team_advanced_stats.value as value, team_advanced_stats.stat_list_id as stat_list_id").where("team_advanced_stats.season_id" => season_id, "team_advanced_stats.is_opponent" => true, "stat_lists.id" => params[:stat][:stat_id]).sort_by{|e| [e.stat_list_id, e.date]}
				else
					##puts "team advanced"
					stats = TeamAdvancedStat.joins([:stat_list, { game: :team }, {game: :opponent}, {:game => :schedule_event}]).select("schedule_events.date as date, stat_lists.stat as stat, opponents.name as opponent_name,  team_advanced_stats.value as value, team_advanced_stats.stat_list_id as stat_list_id").where("team_advanced_stats.season_id" => season_id, "team_advanced_stats.is_opponent" => false, "stat_lists.id" => params[:stat][:stat_id]).sort_by{|e| [e.stat_list_id, e.date]}
				end
			else
				##puts "player advanced"
				stats = AdvancedStat.joins([:stat_list, { :game => :schedule_event}, {game: :opponent}]).select("schedule_events.date as date, stat_lists.stat as stat, advanced_stats.value as value, opponents.name as opponent_name, advanced_stats.stat_list_id as stat_list_id").where("advanced_stats.member_id" => params[:player_id], "stat_lists.rankable" => true, "advanced_stats.season_id" => season_id,  "advanced_stats.stat_list_id" => params[:stat][:stat_id]).sort_by{|e| [e.stat_list_id, e.date]}
			end
		else
			if params[:is_team] == "true"
				if params[:is_opponent] == "true"
					##puts "opponent basic"
					stats = StatTotal.joins([:stat_list, { :game => :schedule_event}, {game: :opponent}]).select("schedule_events.date as date, opponents.name as opponent_name, stat_lists.stat as stat, stat_totals.*").where("stat_lists.team_stat" => false, "stat_totals.season_id" => season_id,"stat_totals.is_opponent" => true,  "stat_lists.rankable" => true, "stat_lists.id" => params[:stat][:stat_id]).sort_by{|e| [e.stat_list_id, e.date]}
				else
					##puts "team basic"
					stats = StatTotal.joins([:stat_list, { :game => :schedule_event}, {game: :opponent}]).select("schedule_events.date as date, opponents.name as opponent_name, stat_lists.stat as stat, stat_totals.*").where("stat_lists.team_stat" => false, "stat_totals.season_id" => season_id, "stat_totals.is_opponent" => false,  "stat_lists.rankable" => true, "stat_lists.id" => params[:stat][:stat_id]).sort_by{|e| [e.stat_list_id, e.date]}
				end
			else
				##puts "player basic"
				stats = Stat.joins([:stat_list, {:game => :schedule_event}, {game: :opponent}]).select("schedule_events.date as date, opponents.name as opponent_name, stat_lists.stat as stat, stats.*").where("stats.member_id" => params[:player_id], "stats.season_id" => season_id, "stat_lists.rankable" => true, "stats.stat_list_id" => params[:stat][:stat_id]).sort_by{|e| [e.stat_list_id, e.date]}
			end
		end
		render :json => {stats: stats}

	end


	def player_profile
		season_id = params[:season_id]
		player = Member.find_by_id(params[:player_id])
		game_data = []
		game_data_ungrouped = Stat.joins([:stat_list, {:game => :schedule_event}, {game: :opponent}]).select("schedule_events.date as date, opponents.name as opponent_name,  stat_lists.stat as stat, stats.*").where("stats.member_id" => params[:player_id], "stats.season_id" => season_id).sort_by{|e| e.date}
		game_data_ungrouped.group_by(&:game_id).each do |game_id, data|
			game_data.push({game_id: game_id, data: data, opponent_name: data[0].opponent_name, date: data[0].date})
		end

		season_stats = SeasonStat.joins(:stat_list, :member).select("stat_lists.stat as stat, stat_lists.display_priority as display_priority, season_stats.*").where('season_stats.member_id' => params[:player_id], "season_stats.season_id" => season_id).sort_by{|e| e.stat_list_id}
		advanced_stats = SeasonAdvancedStat.joins(:stat_list, :member).select("stat_lists.stat as stat, stat_lists.display_priority as display_priority, season_advanced_stats.*").where('season_advanced_stats.member_id' => params[:player_id], "season_advanced_stats.season_id" => season_id).sort_by{|e| e.stat_list_id}
		shot_chart_data = StatGranule.select("stat_granules.*").where('stat_granules.member_id' => params[:player_id], "stat_granules.season_id" => season_id, "stat_granules.stat_list_id"=> [1,2])
		render :json => {game_data: game_data, season_stats: season_stats, shot_chart_data: shot_chart_data, player: player, advanced_stats: advanced_stats}
	end


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
		@write_permiss = true
		@read_permiss = true
	else
		@write_permiss = member.permissions["stats_edit"]
		@read_permiss = member.permissions["stats_view"]
	end
	gon.stats_read = @read_permiss
	gon.stats_write = @write_permiss
end



