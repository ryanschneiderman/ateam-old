class Progressions::CreateProgressionService
	def initialize(params)

		@json_diagram = params[:json_diagram]
		@play_id = params[:play_id]
		@team_id = params[:team_id]
		@user_id = params[:user_id]
		@season_id = params[:season_id]
		@canvas_width = params[:canvas_width]
		@progression_index = params[:progression_index]

		@play_name = params[:play_name]
		@play_image = params[:play_image]
	
	end

	def call()
		play = Play.find_by_id(@play_id)
		team_id = @team_id
		
		member = Member.where(user_id: @user_id, season_id: @season_id).take

		progression = Progression.new(
			json_diagram: @json_diagram, 
			index: play.num_progressions, 
			play_id: play.id, 
			canvas_width: @canvas_width, 
		)
		play.num_progressions = play.num_progressions + 1
		play.updated_at = Time.now
		play.save
		play_name = play.name

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

		notif = Notification.create(
			content: "Play: " + @play_name + " edited",
			season_id: @season_id,
			notif_type_type: "Play",
			notif_type_id: play.id,
			data: {"count" => 1},
			notif_kind: "edited"
		)


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
		end
		return progression.id
	end
end