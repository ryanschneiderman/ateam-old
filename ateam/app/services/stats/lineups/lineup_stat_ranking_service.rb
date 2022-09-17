class Stats::Lineups::LineupStatRankingService
	def initialize(params)
		@team_id = params[:team_id]
		@season_id = params[:season_id]
	end

	def call
		all_rankings = []
		all_rankings_index = 0
		adv_rankings = []
		adv_rankings_index = 0
		minutes_cutoff = Lineup.where(season_id: @season_id).sum(:season_minutes) * 0.01
		puts "MINTUES CUTOFF"
		puts minutes_cutoff
		stats_ungrouped = LineupStat.joins(:stat_list, :lineup).select(" stat_lists.stat as stat, stat_lists.is_percent as is_percent, stat_lists.advanced as advanced, lineups.season_id as season_id, lineup_stats.*, lineups.id as lineup_id, lineups.season_minutes as season_minutes").where('stat_lists.rankable'=> true, 'lineup_stats.is_opponent' => false, 'lineup_stats.season_id' => @season_id).where('lineups.season_minutes > ?' , minutes_cutoff)
		non_cutoff = LineupStat.joins(:stat_list, :lineup).select(" stat_lists.stat as stat, stat_lists.is_percent as is_percent, stat_lists.advanced as advanced, lineups.season_id as season_id, lineup_stats.*, lineups.id as lineup_id, lineups.season_minutes as season_minutes").where('stat_lists.rankable'=> true, 'lineup_stats.is_opponent' => false, 'lineup_stats.season_id' => @season_id).where('lineups.season_minutes < ?' , minutes_cutoff)
		non_cutoff_import = []
		non_cutoff.each do |obj|
			obj.rank = nil
			obj.percentile_rank = nil
			non_cutoff_import.push(obj)
		end


		non_cutoff_import_adv = [] 
		basic_stats = []
		stats_ungrouped.group_by(&:stat_list_id).each do |stat_list_id, stats| basic_stats.push({stat_list_id: stat_list_id, stats: stats, is_percent: stats[0].is_percent}) end
		adv_stats_ungrouped = LineupAdvStat.joins(:stat_list, :lineup).select("stat_lists.stat as stat, stat_lists.advanced as advanced, lineups.season_id as season_id, lineup_adv_stats.*, lineups.season_minutes as season_minutes, lineups.id as lineup_id").where('lineup_adv_stats.is_opponent' => false, 'lineup_adv_stats.season_id' => @season_id).where('lineups.season_minutes > ?' , minutes_cutoff)
		non_cutoff_advanced = LineupAdvStat.joins(:stat_list, :lineup).select("stat_lists.stat as stat, stat_lists.advanced as advanced, lineups.season_id as season_id, lineup_adv_stats.*, lineups.season_minutes as season_minutes, lineups.id as lineup_id").where('lineup_adv_stats.is_opponent' => false, 'lineup_adv_stats.season_id' => @season_id).where('lineups.season_minutes < ?' , minutes_cutoff)
		non_cutoff_advanced.each do |obj|
			obj.rank = nil
			obj.percentile_rank = nil
			non_cutoff_import_adv.push(obj)
		end

		LineupStat.import non_cutoff_import, on_duplicate_key_update: {conflict_target: [:id], columns: [:rank, :percentile_rank, :updated_at]}
		LineupAdvStat.import non_cutoff_import_adv, on_duplicate_key_update: {conflict_target: [:id], columns: [:rank, :percentile_rank, :updated_at]}



		adv_stats = []
		adv_stats_ungrouped.group_by(&:stat_list_id).each do |stat_list_id, stats| adv_stats.push({stat_list_id: stat_list_id, stats: stats}) end	


		update_hash = []
		basic_stats.each do |stat|
			if stat[:is_percent] || stat[:stat_list_id] == 16
				percent_ranks = stat[:stats].sort{|a, b| b.value <=> a.value}
			else
				if(stat[:stat_list_id] == 7 || stat[:stat_list_id] == 17)
					percent_ranks = stat[:stats].sort{|a, b| (get_per_minute_val(a.value, a.season_minutes)) <=> (get_per_minute_val(b.value, b.season_minutes))}
				else
					percent_ranks = stat[:stats].sort{|a, b| (get_per_minute_val(b.value, b.season_minutes)) <=> (get_per_minute_val(a.value, a.season_minutes))}
				end
			end
			percent_rank = 0
			num_stats = percent_ranks.length
			percent_ranks.each do |stat_obj|
				stat_obj.rank = percent_rank
				stat_obj.percentile_rank = 100*(num_stats - percent_rank) /num_stats

				update_hash.push(stat_obj)
				percent_rank+=1
			end
		end
		adv_hash = []
		adv_stats.each do |stat|
			if(stat[:stat_list_id] == 24 || stat[:stat_list_id] == 37 || stat[:stat_list_id] == 30)
				percent_ranks = stat[:stats].sort{|a, b| (a.value <=> b.value)}
			else
				percent_ranks = stat[:stats].sort{|a, b| (b.value <=> a.value)}
			end
			percent_rank = 0
			num_stats = percent_ranks.length

			percent_ranks.each do |stat_obj|
				stat_obj.rank = percent_rank
				stat_obj.percentile_rank = 100*(num_stats - percent_rank) /num_stats
				adv_hash.push(stat_obj)
				percent_rank+=1
			end
		end

		LineupStat.import update_hash, on_duplicate_key_update: {conflict_target: [:id], columns: [:rank, :percentile_rank, :updated_at]}
		LineupAdvStat.import adv_hash, on_duplicate_key_update: {conflict_target: [:id], columns: [:rank, :percentile_rank, :updated_at]}
	end

		private 

	def get_per_minute_val(val, minutes)
		return (val.to_f/(minutes.nonzero? || 1).to_f)
	end
end

