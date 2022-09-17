class Plays::CreatePlayService
	def initialize(params)
		@play_type = params[:play_type]
		@play_name = params[:play_name]
		@is_offense = params[:is_offense]
		@user_id = params[:user_id]
		@json_diagram = params[:json_diagram]
		@canvas_width = params[:canvas_width]
		@team_id = params[:team_id]
		@play_image = params[:play_image]
		@member_id = params[:member_id]
		@playlist_ids = params[:playlist_ids]
		@season_id = params[:season_id]
	end

	def call()

		play = Play.new(
			name: @play_name,
			user_id: @user_id,
			num_progressions: 1,
			play_type_id: @play_type,
			deleted_flag: false,
		)
		play.save!
		if @playlist_ids
			@playlist_ids.each do |playlist_id|
				playlist = Playlist.find_by_id(playlist_id)
				playlist_association = PlaylistAssociation.new(play: play, playlist: playlist)
				playlist_association.save!
			end
		end

		notif = Notification.create(
			content: "New play: " + @play_name + " created",
			notif_type_type: "Play",
			notif_type_id: play.id,
			notif_kind: "created",
			season_id: @season_id
		)

		progression = Progression.new(
			json_diagram: @json_diagram, 
			index: 0, 
			play_id: play.id, 
			canvas_width: @canvas_width, 
		)

		progression_str = play.name + "1.png"
		param_data = @play_image
		image_data = Base64.decode64(param_data['data:image/png;base64,'.length .. -1])
		image = MiniMagick::Image.read(image_data)
		image.format("png")

		progression.play_image.attach(io: StringIO.new(image.to_blob), filename: progression_str, content_type: "image/jpeg")
		if progression.valid?
			puts "progression valid"
		else 
			puts "progression invalid"
		end
		progression.save

		members = Member.where(season_id: @season_id)
		members.each do |team_member|
			if team_member.id != @member_id
				MemberNotif.create(
					member_id: team_member.id,
					notification_id: notif.id,
					viewed: false,
					read: false,
				)
			else
				MemberNotif.create(
					member_id: team_member.id,
					notification_id: notif.id,
					viewed: true,
					read: true,
				)

			end
			PlayView.create({
				member_id: team_member.id,
				play_id: play.id,
				viewed: Time.new(0)   
			})
		end



		Plays::UpdatePlayViewedService.new({play_id: play.id, member_id: @member_id}).call
		return {play_id: play.id, progression_id:  progression.id}
	end
end