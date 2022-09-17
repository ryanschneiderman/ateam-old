class Teams::TeamStatService
	def initialize(params)
		@team_stats = params[:team_stats]
		@team_id = params[:team_id]
		@season_id = params[:season_id]
		@players = Member.where(season_id: @season_id, is_player: true)
		@player_season_stat_hash = []
	end

	def call
		(@team_stats || []).each do |stat_id|
			TeamStat.create(
				stat_list_id: stat_id,
				show: true,
				season_id: @season_id,
			)
			init_player_stats(stat_id)
		end
	end

	private 

	def init_player_stats(ts)
		case ts
		when 1
			init_player_stat(ts)
		when 2
			init_player_stat(ts)
		when 3
			init_player_stat(ts)
		when 4
			init_player_stat(ts)
		when 5
			init_player_stat(ts)
		when 6
			init_player_stat(ts)
		when 7
			init_player_stat(ts)
		when 8
			init_player_stat(ts)
		when 11
			init_player_stat(ts)
		when 12
			init_player_stat(ts)
		when 13
			init_player_stat(ts)
		when 14
			init_player_stat(ts)
		when 15
			init_player_stat(ts)
		when 16
			init_player_stat(ts)
		when 17
			init_player_stat(ts)
		end
	end

	def init_player_stat(ts)
		@players.each do |player|
			@player_season_stat_hash.push({
				value: 0,
				stat_list_id: ts,
				member_id: player.id,
				season_id: @season_id
			})
		end
	end

	def import_season_stats
		SeasonStat.import @player_season_stat_hash
	end
end