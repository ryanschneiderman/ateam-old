class Stats::StatRankingsService
	def initialize(params)
		@season_id = params[:season_id]
	end

	def call
		all_rankings = []
		all_rankings_index = 0
		stats = SeasonStat.joins(:stat_list, :member).select("members.games_played as games_played, members.season_minutes as season_minutes, stat_lists.is_percent as is_percent, stat_lists.advanced as advanced, season_stats.*").where('members.season_id' => @season_id, 'stat_lists.rankable'=> true).sort_by{|e| [e.stat_list_id]}
		adv_stats = SeasonAdvancedStat.joins(:stat_list, :member).select("stat_lists.is_percent as is_percent, stat_lists.advanced as advanced, season_advanced_stats.*").where('members.season_id' => @season_id, 'stat_lists.rankable'=> true).sort_by{|e| [e.stat_list_id]}

		curr_stat_list = stats[0].stat_list_id
		all_rankings.append([])

		stats.each do |stat|
			if stat.stat_list_id != curr_stat_list
				new_array = []
				curr_stat_list = stat.stat_list_id
				new_array.append(stat)
				all_rankings.append(new_array)
				all_rankings_index +=1
			else
				all_rankings[all_rankings_index].append(stat)
			end
		end
		all_rankings.append([])
		all_rankings_index+=1

		if adv_stats
		   curr_stat_list = adv_stats[0].stat_list_id
		   adv_stats.each do |adv_stat|
				if adv_stat.stat_list_id != curr_stat_list
					new_array = []
					curr_stat_list = adv_stat.stat_list_id
					new_array.append(adv_stat)
					all_rankings.append(new_array)
					all_rankings_index +=1
				else
					all_rankings[all_rankings_index].append(adv_stat)
				end
			end
		end
		

		all_rankings.each do |ranking|
			if ranking[0].is_percent
				if(ranking[0].stat_list_id == 24 or ranking[0].stat_list_id == 37)
					percent_ranks = ranking.sort{|a, b| (a.value <=> b.value)}
				else	
					percent_ranks = ranking.sort{|a, b| (b.value <=> a.value)}
				end
				percent_rank = 0 
				if percent_ranks[0].advanced
					percent_ranks.each do |stat|
						stat.update_attribute(:team_rank, percent_rank)
						percent_rank +=1
					end
				else
					percent_ranks.each do |stat|
						stat.update_attribute(:per_game_rank, percent_rank)
						stat.update_attribute(:per_minute_rank, percent_rank)
						percent_rank +=1
					end
				end
			else
				if(ranking[0].stat_list_id == 7 || ranking[0].stat_list_id == 17)
					per_game_ranks = ranking.sort{|a, b| (get_per_game_val(a.value, a.games_played)) <=> (get_per_game_val(b.value, b.games_played))}
					per_minute_ranks = ranking.sort{|a, b| (get_per_minute_val(a.value, a.season_minutes)) <=> (get_per_minute_val(b.value, b.season_minutes))}
				else	
					per_game_ranks = ranking.sort{|a, b| (get_per_game_val(b.value, b.games_played)) <=> (get_per_game_val(a.value, a.games_played))}
					per_minute_ranks = ranking.sort{|a, b| (get_per_minute_val(b.value, b.season_minutes)) <=> (get_per_minute_val(a.value, a.season_minutes))}
				end

				per_game_rank = 0
				per_game_ranks.each do |stat|
					stat.update_attribute(:per_game_rank, per_game_rank)
					per_game_rank +=1
				end
				per_minute_rank = 0
				per_minute_ranks.each do |stat|
					stat.update_attribute(:per_minute_rank, per_minute_rank)
					per_minute_rank +=1
				end
			end
		end
	end

	private 

	def get_per_minute_val(val, minutes)
		return (val/(minutes.nonzero? || 1)).to_f 
	end

	def get_per_game_val(val, games)
		return (val/(games.nonzero?|| 1)).to_f
	end

end

