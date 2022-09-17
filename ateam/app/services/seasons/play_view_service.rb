class Seasons::PlayViewService
	def initialize(params)
		@team_id = params[:team_id]
		@season_id = params[:season_id]
	end

	def call
		all_plays =  Play.joins(:team_plays).select("team_plays.team_id as team_id, plays.*").where( "team_plays.team_id"=>@team_id, "plays.deleted_flag" => false)
		members = Member.where(season_id: @season_id)
		all_plays.each do |play|
			members.each do |m|
				PlayView.create({
					member_id: m.id,
					play_id: play.id,
					viewed: Time.new(0)  
				})
			end
		end
	end


end





