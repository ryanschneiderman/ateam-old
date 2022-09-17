class Plays::CreateInitialPlaylistsService
	def initialize(params)
		@team_id = params[:team_id]
	end

	def call()
		playlist = Playlist.create(name: "Offense", team_id: @team_id, color_scheme: 1)
		playlist = Playlist.create(name: "Defense", team_id: @team_id, color_scheme: 2)
		playlist = Playlist.create(name: "Inbounds", team_id: @team_id, color_scheme: 3)
	end
end