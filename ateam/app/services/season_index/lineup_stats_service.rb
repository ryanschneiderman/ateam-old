### get the lineup object for the lineups with the highest offensive, defensive and net efficiency. 
### Modularize to get the lineup object for the top *insert stat_list_id*


class SeasonIndex::LineupStatsService
	def initialize(params)
		@team_id = params[:team_id]
		@season_id = params[:season_id]
		@stat_list_id = params[:stat_list_id]
	end

	def call()
		minutes_cutoff = Lineup.where(season_id: @season_id).sum(:season_minutes) * 0.01
		
		if is_advanced(@stat_list_id)
			lineup =  LineupAdvStat.joins(:stat_list, :lineup).select("stat_lists.stat as stat, stat_lists.abbr as abbr, stat_lists.stat_kind as stat_kind, stat_lists.display_priority as display_priority, lineup_adv_stats.*, lineups.id as lineup_id").where("lineup_adv_stats.is_opponent" => false, "lineup_adv_stats.season_id" => @season_id, "stat_lists.id" => @stat_list_id).where('lineups.season_minutes > ?' , minutes_cutoff).paginate(page: @page, per_page:10).order('percentile_rank DESC, value DESC').take
		else
			lineup =  LineupStat.joins(:stat_list, :lineup).select("stat_lists.stat as stat, stat_lists.abbr as abbr, stat_lists.stat_kind as stat_kind, stat_lists.display_priority as display_priority, lineup_stats.*, lineups.id as lineup_id").where("lineup_stats.is_opponent" => false, "lineup_stats.season_id" => @season_id, "stat_lists.id" => @stat_list_id).where('lineups.season_minutes > ?' , minutes_cutoff).paginate(page: @page, per_page:10).order('percentile_rank DESC, value DESC').take
		end

		#lineups = Lineup.where(season_id: @season_id).paginate(page: 1, per_page:15).order('season_minutes DESC')
		if lineup.present?
			lineup_members = LineupsMember.joins(:member).select("members.nickname as name, lineups_members.*").where("lineups_members.lineup_id" => lineup.lineup_id)
			lineup_adv_stats = LineupAdvStat.joins(:stat_list, :lineup).select("stat_lists.stat as stat, stat_lists.abbr as abbr, stat_lists.display_priority as display_priority, lineup_adv_stats.*, lineups.id as lineup_id").where("lineup_adv_stats.lineup_id" => lineup.lineup_id, "lineup_adv_stats.is_opponent" => false)
			lineup_obj = { advanced_stats: lineup_adv_stats, lineup_members: lineup_members, lineup_id: lineup.lineup_id}
		end

		return lineup_obj
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