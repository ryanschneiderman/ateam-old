class Seeds::Receivers::ReceiveSeedDataService
	def initialize(params)
		@data = params[:data]
		@data_kind = params[:data_kind]
	end

	def call
		case @data_kind
		when "player_game_log"
			Seeds::Receivers::SeedGameLogDataService.new({data: @data}).call
		when "team_game_log"
			Seeds::Receivers::SeedTeamGameLogDataService.new({data: @data}).call
		when "opponent_game_log"
			Seeds::Receivers::SeedOpponentGameLogDataService.new({data: @data}).call
		when "shot_data"
			Seeds::Receivers::SeedShotDataService.new({data: @data}).call
		when "season_stats"
			Seeds::Receivers::SeedSeasonStatService.new({data: @data}).call
		when "lineup_stats"
			Seeds::Receivers::SeedLineupStatService.new({data: @data}).call
		when "lineup_opponent"
			Seeds::Receivers::SeedLineupOpponentStatService.new({data: @data}).call
		end
		
	end
end