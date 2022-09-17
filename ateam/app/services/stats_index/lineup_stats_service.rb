class StatsIndex::LineupStatsService
	def initialize(params)
		@team_id = params[:team_id]
		@season_id = params[:season_id]
		@sorting_stat = params[:sorting_stat]
		@page = params[:page]
	end

	def call()
		minutes_cutoff = Lineup.where(season_id: @season_id).sum(:season_minutes) * 0.01
		puts "minutes_cutoff"
		puts minutes_cutoff
		if is_advanced(@sorting_stat)
			lineups =  LineupAdvStat.joins(:stat_list, :lineup).select("stat_lists.stat as stat, stat_lists.abbr as abbr, stat_lists.stat_kind as stat_kind, stat_lists.display_priority as display_priority, lineup_adv_stats.*, lineups.id as lineup_id").where("lineup_adv_stats.is_opponent" => false, "lineup_adv_stats.season_id" => @season_id, "stat_lists.id" => @sorting_stat).where('lineups.season_minutes > ?' , minutes_cutoff).paginate(page: @page, per_page:10).order('percentile_rank DESC, value DESC')
		else
			lineups =  LineupStat.joins(:stat_list, :lineup).select("stat_lists.stat as stat, stat_lists.abbr as abbr, stat_lists.stat_kind as stat_kind, stat_lists.display_priority as display_priority, lineup_stats.*, lineups.id as lineup_id").where("lineup_stats.is_opponent" => false, "lineup_stats.season_id" => @season_id, "stat_lists.id" => @sorting_stat).where('lineups.season_minutes > ?' , minutes_cutoff).paginate(page: @page, per_page:10).order('percentile_rank DESC, value DESC')
		end
		#lineups = Lineup.where(season_id: @season_id).paginate(page: 1, per_page:15).order('season_minutes DESC')
		lineups_arr = []
		lineups.each do |lineup|
			lineup_members = LineupsMember.joins(:member).select("members.nickname as name, lineups_members.*").where("lineups_members.lineup_id" => lineup.lineup_id)
			lineup_stats = LineupStat.joins(:stat_list, :lineup).select("stat_lists.stat as stat, stat_lists.abbr as abbr, stat_lists.stat_kind as stat_kind, stat_lists.display_priority as display_priority, lineup_stats.*, lineups.id as lineup_id").where("lineup_stats.lineup_id" => lineup.lineup_id, "lineup_stats.is_opponent" => false)
			lineup_opponent_stats = LineupStat.joins(:stat_list, :lineup).select("stat_lists.stat as stat, stat_lists.abbr as abbr, stat_lists.stat_kind as stat_kind, stat_lists.display_priority as display_priority, lineup_stats.*, lineups.id as lineup_id").where("lineup_stats.lineup_id" => lineup.lineup_id, "lineup_stats.is_opponent" => true)
			lineup_adv_stats = LineupAdvStat.joins(:stat_list, :lineup).select("stat_lists.stat as stat, stat_lists.abbr as abbr, stat_lists.display_priority as display_priority, lineup_adv_stats.*, lineups.id as lineup_id").where("lineup_adv_stats.lineup_id" => lineup.lineup_id, "lineup_adv_stats.is_opponent" => false)
			lineups_arr.push({stats: lineup_stats, opponent_stats: lineup_opponent_stats, advanced_stats: lineup_adv_stats, lineup_members: lineup_members, lineup_id: lineup.lineup_id})
		end

		return lineups_arr
	end

	private

	def is_advanced(stat_id)

		stat_id = stat_id.to_i
		if stat_id ==  29 || stat_id == 30 || stat_id == 18 || stat_id == 19 || stat_id == 32 || stat_id == 33 || stat_id == 25
			return true
		else
			return false
		end
	end

	
end