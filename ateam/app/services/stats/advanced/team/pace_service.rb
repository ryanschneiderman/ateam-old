class Stats::Advanced::Team::PaceService
	def initialize(params)
		@possessions = params[:possessions]
		@opp_possessions = params[:opp_possessions]
		@team_minutes = params[:team_minutes]
		@minutes_per_game = params[:minutes_per_game]
		puts "@minutes per game"
		puts @minutes_per_game
		puts "@team_minutes"
		puts @team_minutes
		puts "@possessions"
		puts @possessions
		puts "@opp_possessions"
		puts @opp_possessions
	end

	def call()
		pace = 100 * @minutes_per_game * ((@possessions + @opp_possessions) / (2 * (@team_minutes / 5)))
		pace = pace.round / 100.0
		puts "@pace"
		puts pace
		return pace
	end
end


## 48 * ((Tm Poss + Opp Poss) / (2 * (Tm MP / 5)))