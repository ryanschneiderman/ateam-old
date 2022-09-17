class Teams::CreateTeamMembersService
	def initialize(params)
		@members = params[:members]
		@team_id = params[:team_id]
		@season_id = params[:season_id]
	end

	def call
		(@members || []).each do |new_member|
			json = get_permissions_json(new_member[1])
			new_member = new_member[1]
			member = Member.new({
				nickname: new_member[:name],
				season_minutes: 0,
				games_played: 0,
				permissions: json,
				email: new_member[:email],
				is_player: new_member[:is_player],
				is_admin: false,
				season_id: @season_id,
				number: new_member[:number]
			})

			member.save!

			validate = Truemail.validate(new_member[:email], with: :regex)
			if validate.result.success
				MyMailer.send_join_email(name: new_member[:name], email: new_member[:email], team_id: @team_id, season_id: @season_id, member_id: member.id).deliver
			end
			create_member_role(member, new_member[:role_name])

		end
	end

	private 

	def create_member_role(member, member_role)
		case member_role
		when "Player"
			Assignment.create({
				member_id: member.id,
				role_id: 1
			})
		when "Coach"
			Assignment.create({
				member_id: member.id,
				role_id: 2
			})
		when "Manager"
			Assignment.create({
				member_id: member.id,
				role_id: 3
			})
		when "Other"
			Assignment.create({
				member_id: member.id,
				role_id: 5
			})
		end
	end

	def get_permissions_json(member)
		case member[:role_name]
		when "Player"
			return get_player_permissions(member)
		when "Coach"
			return get_coach_permissions(member)
		when "Manager"
			return get_manager_permissions(member)
		when "Other"
			return get_other_permissions(member)
		end
	end

	def get_player_permissions(member)
		{"plays_view" => true, "plays_edit" => false, "schedule_view" => true, "schedule_edit" => false, "stats_view" => true, "stats_edit" => false, "settings_view" => true, "settings_edit" => false , "chat_access_read" => member[:permissions][:chat_access_read].downcase == "true", "chat_access_write" => member[:permissions][:chat_access_write].downcase == "true"}
	end

	def get_coach_permissions(member)
		{"plays_view" => true, "plays_edit" => true, "schedule_view" => true, "schedule_edit" => true, "stats_view" => true, "stats_edit" => true, "settings_view" => true, "settings_edit" => true , "chat_access_read" => member[:permissions][:chat_access_read].downcase == "true", "chat_access_write" => member[:permissions][:chat_access_write].downcase == "true"}
	end

	def get_manager_permissions(member)
		{"plays_view" => true, "plays_edit" => false, "schedule_view" => true, "schedule_edit" => false, "stats_view" => true, "stats_edit" => false, "settings_view" => true, "settings_edit" => false , "chat_access_read" => member[:permissions][:chat_access_read].downcase == "true", "chat_access_write" => member[:permissions][:chat_access_write].downcase == "true"}
	end

	def get_other_permissions(member)
		{"plays_view" => member[:permissions][:plays_view].downcase == "true", "plays_edit" => member[:permissions][:plays_edit].downcase == "true", "schedule_view" => member[:permissions][:schedule_view].downcase == "true", "schedule_edit" => member[:permissions][:schedule_edit].downcase == "true", "stats_view" => member[:permissions][:stats_view].downcase == "true", "stats_edit" => member[:permissions][:stats_edit].downcase == "true", "settings_view" => member[:permissions][:settings_view].downcase == "true", "settings_edit" => member[:permissions][:settings_edit].downcase == "true" , "chat_access_read" => member[:permissions][:chat_access_read].downcase == "true", "chat_access_write" => member[:permissions][:chat_access_write].downcase == "true"}
	end


end





