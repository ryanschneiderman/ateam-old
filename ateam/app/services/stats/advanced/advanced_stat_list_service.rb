class Stats::Advanced::AdvancedStatListService
	def initialize(params)
		@season_id = params[:season_id]
	end

	def call()
		advanced_stat_list = [] 
		adv_stat_instance = TeamStat.where(season_id: @season_id).joins(:stat_list).where('stat_lists.advanced' => true, 'stat_lists.team_stat' =>false);
		adv_stat_instance.each do |stat|
			advanced_stat_list.push(StatList.find_by_id(stat.stat_list_id))
		end

		adv_stat_table_columns = Stats::StatTableColumnsService.new({
			stats: advanced_stat_list,
			is_advanced: true,
			is_team: false,
		}).call
		return adv_stat_table_columns
	end
end