class Stats::Advanced::AdvStatDependenciesService

	def initialize(params)
		@adv_stats = params[:adv_stats]
	end

	def call()
		return_arr = []
		@adv_stats.each do |adv_stat|
			stat = determine_dependencies(adv_stat.id, adv_stat.stat)
			if stat 
				return_arr.push(stat)
			end
		end
		##puts return_arr
		return_arr.each do |this|
			##puts this
		end
		return return_arr
	end

	private

	def determine_dependencies(stat_id, stat_name)
		case stat_id
		##usage rate
		when 22
			return {stat_id: stat_id, stats_needed: [ 7, ], stats_satisfied: [1, 2, 13, 14, 16], name: stat_name}

		## offensive rating
		when 23
			return {stat_id: stat_id, stats_needed: [ 3, 4, 5, 7 ], stats_satisfied: [1, 2, 9, 10 , 11, 12,13, 14, 15, 16], name: stat_name}

		##defensive rating
		when 24
			return {stat_id: stat_id, stats_needed: [4,5,6,7,8 ], stats_satisfied: [1, 2, 9, 10, 13, 14, 15, 16], name: stat_name}

		##net rating
		when 25
			return {stat_id: stat_id, stats_needed: [ 3, 4, 5, 6, 7, 8, ], stats_satisfied: [1, 2, 9, 10 , 11, 12,13, 14, 15, 16], name: stat_name}

		##off reb%
		when 32
			return {stat_id:stat_id,  stats_needed:[ 4,5 ], stats_satisfied: [16], name: stat_name}
		##def reb%
		when 33
			return {stat_id: stat_id, stats_needed: [ 4,5 ], stats_satisfied: [16], name: stat_name}
		##reb %
		when 34
			return {stat_id: stat_id, stats_needed: [ 4,5 ], stats_satisfied: [16], name: stat_name}
		## steal%
		when 35
			return {stat_id: stat_id, stats_needed: [ 6, 4, 7 ], stats_satisfied: [1, 2, 11, 12, 16], name: stat_name}
		## block %
		when 36
			return {stat_id: stat_id, stats_needed: [ 8, 4, 7 ], stats_satisfied: [1, 2, 11, 12,16], name: stat_name}
		## turnover%
		when 37
			return {stat_id: stat_id, stats_needed: [ 7 ], stats_satisfied: [1, 2, 13, 14], name: stat_name}
		## assist %
		when 38
			return {stat_id: stat_id, stats_needed: [ 3 ], stats_satisfied: [1, 2, 16], name: stat_name}
		## off box plus minus
		when 39
			return {stat_id: stat_id, stats_needed: [ 3, 4, 5, 6, 7, 8, ], stats_satisfied: [1, 2, 9, 10 , 11, 12,13, 14, 15, 16], name: stat_name}
		## def box plus minus
		when 40
			return {stat_id: stat_id, stats_needed: [ 3, 4, 5, 6, 7, 8, ], stats_satisfied: [1, 2, 9, 10 , 11, 12,13, 14, 15, 16], name: stat_name}
		## box plus minus
		when 41
			return {stat_id: stat_id, stats_needed: [ 3, 4, 5, 6, 7, 8, ], stats_satisfied: [1, 2, 9, 10 , 11, 12,13, 14, 15, 16], name: stat_name}
		when 45
			return {stat_id: stat_id, stats_needed: [ 3, 4, 5, 6, 7, 8, ], stats_satisfied: [1, 2, 9, 10 , 11, 12,13, 14, 15, 16], name: stat_name}
		when 46
			return {stat_id: stat_id, stats_needed: [ 3, 4, 5, 6, 7, 8, ], stats_satisfied: [1, 2, 9, 10 , 11, 12,13, 14, 15, 16], name: stat_name}
		end


	end
end
