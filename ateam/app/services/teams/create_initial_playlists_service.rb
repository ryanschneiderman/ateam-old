class Teams::CreateSeasonService
	def initialize(params)
		@members = params[:members]
		@team_id = params[:team_id]
	end

	def call
		off = Playlist.create(name: "Offense", team_id: @team_id, color_scheme: 1)
		defense = Playlist.create(name: "Defense", team_id: @team_id, color_scheme: 2)
		inbounds = Playlist.create(name: "Inbounds", team_id: @team_id, color_scheme: 3)
	end

end

