class Seasons::OldMemberPermissionsService
	def initialize(params)
		@season_id = params[:season_id]
		@members = Member.where(season_id: @season_id)
	end

	def call
		(@members || []).each do |member|
			# if !member.is_admin
				assignment = Assignment.where(member_id: member.id)
				assignment.update(role_id: 5)
				member.update(permissions_backup: member.permissions)

				member.permissions = {"plays_view" => false, "plays_edit" => false, "schedule_view" => true, "schedule_edit" => false, "stats_view" => true, "stats_edit" => false, "settings_view" => true, "settings_edit" => false, "chat_access_read" => true, "chat_access_write" => true }
				member.save
			# end
		end
	end
end





