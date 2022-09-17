class DeleteSeasonService
	def initialize(params)
		@season_id = params[:season_id]
	end

	def call()
		AdvancedStat.where(season_id: @season_id).delete_all
		SeasonAdvancedStat.where(season_id: @season_id).delete_all
		SeasonStat.where(season_id: @season_id).delete_all 
		StatGranule.where(season_id: @season_id).delete_all
		Stat.where(season_id: @season_id).delete_all
		OpponentGranule.where(season_id: @season_id).delete_all
		LineupStat.where(season_id: @season_id).delete_all
		LineupGameStat.where(season_id: @season_id).delete_all
		LineupGameAdvancedStat.where(season_id: @season_id).delete_all
		LineupAdvStat.where(season_id: @season_id).delete_all 
		SeasonTeamAdvStat.where(season_id: @season_id).delete_all
		StatTotal.where(season_id: @season_id).delete_all
		TeamSeasonStat.where(season_id: @season_id).delete_all
		TeamAdvancedStat.where(season_id: @season_id).delete_all 
		PracticeStatGranule.where(season_id: @season_id).delete_all
		PracticeStatTotal.where(season_id: @season_id).delete_all
		PracticeStat.where(season_id: @season_id).delete_all
		Game.where(season_id: @season_id).delete_all
		
		TeamStat.where(season_id: @season_id).delete_all
		Post.where(season_id: @season_id).delete_all 
		Notification.where(season_id: @season_id).delete_all
		Assignment.joins(member: :season).select("seasons.*").where("seasons.id" => @season_id).delete_all
		Member.where(season_id: @season_id).destroy_all 
		Season.find_by_id(@season_id).destroy
	end
end


