class PlaysController < ApplicationController
	skip_before_action :authenticate_user!, only: [:play_demo]
	before_action :verify_team_paid, :authenticate_member, :verify_member
	def index

		# schedule_events = ScheduleEvent.all 
		# schedule_events.each do |event|
		# 	team_id = event.team_id
		# 	puts team_id
		# 	event.update_attributes!(season_id: team_id)
		# end

		# Seasons::PlayViewService.new({
		# 	team_id: params[:team_id],
		# 	season_id: params[:season_id],
		# }).call

		@team_id = params[:team_id]
		@season_id = params[:season_id]

		@season = Season.find_by_id(params[:season_id])

		member = Member.where(user_id: current_user.id, season_id: @season_id).take
		if !member && current_user.admin
			member = Member.where( season_id: @season_id).take
		end

		
		
		@all_plays =  Play.joins(:team_plays, :play_views).select("team_plays.team_id as team_id, play_views.member_id as member_id, play_views.viewed as viewed, plays.*").where( "team_plays.team_id"=>params[:team_id], "plays.deleted_flag" => false, "play_views.member_id" => member.id).sort_by{|e| e.name}
		@all_plays_progressions = []
		@all_plays.each do |play|
			all_plays_progression = Progression.where(:play_id => play.id).sort_by{|e| e.index}
			@all_plays_progressions.append(all_plays_progression)
		end

		@deleted_plays =  Play.joins(:team_plays, :play_type).select("play_types.play_type as p_type, team_plays.team_id as team_id, plays.*").where( "team_plays.team_id"=>params[:team_id], "plays.deleted_flag" => true).sort_by{|e| e.name}
		@deleted_plays_progressions = []
		@deleted_plays.each do |play|
			deleted_plays_progression = Progression.where(:play_id => play.id).sort_by{|e| e.index}
			@deleted_plays_progressions.append(deleted_plays_progression)
		end

		@recently_viewed = Play.joins(:team_plays, :play_views).select("plays.*, team_plays.team_id as team_id, play_views.member_id as member_id, play_views.viewed as viewed").where("team_plays.team_id" => params[:team_id], "plays.deleted_flag" => false, "play_views.member_id" => member.id).sort_by{|e| e.viewed}.reverse!.first(4)
		@recently_viewed_progressions = []
		@recently_viewed.each do |play|
			recently_viewed_progression = Progression.where(:play_id => play.id).sort_by{|e| e.index}
			@recently_viewed_progressions.append(recently_viewed_progression)
		end

		@recently_updated =  Play.joins(:team_plays).select("team_plays.team_id as team_id, plays.*").where("team_plays.team_id"=>params[:team_id], "plays.deleted_flag" => false).sort_by{|e| e.updated_at}.reverse!.first(4)
		@recently_updated_progressions = []
		@recently_updated.each do |play|
			recently_updated_progression = Progression.where(:play_id => play.id).sort_by{|e| e.index}
			@recently_updated_progressions.append(recently_updated_progression)
		end


		@playlist_arr = []
		@playlists = Playlist.where(team_id: params[:team_id]).sort_by{|e| e.id}
		@playlists.each do |playlist|
			playlist_associations = PlaylistAssociation.joins(:play).select("playlist_associations.*, plays.deleted_flag as deleted_flag").where("playlist_associations.playlist_id" => playlist.id, "plays.deleted_flag" => false)
			playlist_imgs = []
			playlist_associations.each do |playlist_assoc|
				progressions = Progression.where(play_id: playlist_assoc.play_id)
				play = Play.find_by_id(playlist_assoc.play_id)
				if progressions[0].present?
					progression_img = progressions[0].play_image
				end
				# if !progression_img
				# 	progression_img = 1
				# end
				playlist_imgs.push({progression_img: progression_img, play_id: playlist_assoc.play_id, play_name: play.name})
			end
			@playlist_arr.push({playlist: playlist, playlist_imgs: playlist_imgs})
		end
		

		@play_types = PlayType.all()

		gon.team_id = @team_id
		gon.season_id = params[:season_id]
	end

	def new
		@play_type = params[:play_type]
		@play_name = params[:play_name]
		@playlists = params[:playlists]
		gon.playlists = @playlists
		gon.play_type = @play_type


		@play = Play.new(
			name: @play_name,
			user_id: current_user.id,
			num_progressions: 0,
			play_type_id: @play_type,
		)

		progression = Progression.new(
			index: 0, 
			play_id: @play.id, 
		)
		@play_id = @play.id

		##playlist_associations

		@progression_id = progression.id
		gon.season_id = params[:season_id]
		@team_id = params[:team_id]
		@season = Season.find_by_id(params[:season_id])
		gon.season = @season
		gon.primary_color = @season.primary_color
		gon.secondary_color = @season.secondary_color
		gon.team_id = @team_id
		#@offense_defense = params[:is_offense]
		@play_types = PlayType.all()
	end	

	def new_play
		team_id = params[:team_id]
		season_id = params[:season_id]
		playlists = params[:playlists]
		play_name = params[:play_name]
		play_type = params[:play_type]

		redirect_to new_team_season_play_path(team_id, season_id, playlists: playlists, play_name: play_name, play_type: play_type, season_id: season_id)
	end
	
	##service
	def create
		play_name = params[:play_name]
		is_offense = params[:offense_defense]
		play_type = params[:play_type]
		team_id = params[:team_id]
		create_next = params[:create_next]
		playlist_ids = params[:playlists]
		member = Member.where(user_id: current_user.id, season_id: params[:season_id]).take

		ids = Plays::CreatePlayService.new({
			play_type: play_type,
			play_name: play_name,
			is_offense: is_offense,
			user_id: current_user.id,
			json_diagram: params[:json_diagram],
			canvas_width: params[:canvas_width],
			team_id: team_id,
			play_image: params[:play_image],
			member_id: member.id,
			playlist_ids: playlist_ids,
			season_id: params[:season_id]
		}).call
		


		if params[:team_id]
			@team_play = TeamPlay.new(play_id: ids[:play_id], team_id: params[:team_id])
			@team_play.save
		end
		render :json => {progression_id: ids[:progression_id], play_id: ids[:play_id]}
	end


	##service
	def show
		member = Member.where(user_id: current_user.id, season_id: params[:season_id]).take
		if current_user.admin 
			@write_permiss = true
			@read_permiss = true
		else
			@write_permiss = member.permissions["plays_edit"]
			@read_permiss = member.permissions["plays_view"]
		end
		if @write_permiss
			puts "should redirect"
			redirect_to edit_team_season_play_path(params[:team_id], params[:season_id], params[:id])
		end
		puts "@write permiss"
		puts @write_permiss
		param_play = Play.find_by_id(params[:id])

		## make sure to sanitize
		param_play_id = params[:id]
		@play_type = PlayType.find_by_id(param_play.play_type_id)
		@team_id = cookies[:team_id]
		if param_play.num_progressions == 0 
			@need_new_progression_link = true
		else 
			@need_new_progression_link = false
		end

		gon.season_id = params[:season_id]
		@season = Season.find_by_id(params[:season_id])

		gon.team_id = @team_id

		@play = param_play
		@progressions = Progression.where(play_id: @play.id).order(:index)
		gon.progressions = @progressions
		members = Member.where(user_id: current_user.id, season_id: params[:season_id]).sort_by{|e| e.season_id}.reverse!
		@member = members.first
		if @member.present?
			@play_notifications = Notification.joins(:member_notifs).select("notifications.*, member_notifs.member_id,  member_notifs.data as member_data, member_notifs.id as member_notif_id").where("member_notifs.member_id" => @member.id, "notifications.notif_type_type" => "Play", "notifications.notif_type_id" => param_play_id)
			@play_notifications.each do |play|
				MemberNotif.find_by_id(play.member_notif_id).update(read: true)
			end
			Plays::UpdatePlayViewedService.new({play_id: @play.id, member_id: @member.id}).call
		end
	end

	def edit 
		param_play = Play.find_by_id(params[:id])
		## make sure to sanitize
		param_play_id = params[:id]
		@team_id = cookies[:team_id]

		gon.season_id = params[:season_id]

		gon.team_id = @team_id
		@play_type = param_play.play_type_id

		if param_play.num_progressions == 0 
			@need_new_progression_link = true
		else 
			@need_new_progression_link = false
		end

		members = Member.where(user_id: current_user.id, season_id: params[:season_id]).sort_by{|e| e.season_id}.reverse!
		member = members.first
		@play = param_play
		@progressions = Progression.where(play_id: @play.id).order(:index)
		gon.progressions = @progressions
		if member.present?
			@play_notifications = Notification.joins(:member_notifs).select("notifications.*, member_notifs.member_id,  member_notifs.data as member_data, member_notifs.id as member_notif_id").where("member_notifs.member_id" => member.id, "notifications.notif_type_type" => "Play", "notifications.notif_type_id" => param_play_id)
			@play_notifications.each do |play|
				puts "PLAY NOTIFICATION"
				MemberNotif.find_by_id(play.member_notif_id).update(read: true)
			end
			Plays::UpdatePlayViewedService.new({play_id: @play.id, member_id: member.id}).call
		end

		@season = Season.find_by_id(params[:season_id])
		gon.season = @season
		gon.primary_color = @season.primary_color
		gon.secondary_color = @season.secondary_color

		

	end

	def update_name
		play_id = params[:play_id]
		play = Play.find_by_id(play_id)
		play_name = params[:play_name]
		play.update(name: play_name)
	end

	def update
		play_id = params[:id]
		team_id = params[:team_id]
		play = Play.find_by_id(play_id)
		play_name = params[:play_name]
		puts "SEASON ID"
		puts params[:season_id]
		play.update(name: play_name)
		raw_data = params[:progressions_data]
		payload = ""
		if raw_data 
			raw_data.each do |data|
				data_cluster = data[1]
				 payload = Progressions::UpdateProgressionsService.new({
					json_diagram: data_cluster[:json_diagram],
					progression_id: data_cluster[:progression_id],
					play_id: play_id,
					team_id: team_id,
					play_name: play_name,
					play_image: data_cluster[:play_image],
					notes: data_cluster[:notes],
					canvas_width: data_cluster[:canvas_width],
					current_user_id: current_user.id,
					season_id: params[:season_id]
				}).call
			end
			render :json => {created_progression: payload}
		else
			render :json => {}
		end
		
		
	end

	def soft_delete
		play = Play.find_by_id(params[:play_id])
		
		progression = Progression.where(play_id: play.id)
		if progression.present? && progression[0].play_image.attached?
			progression_img = url_for(progression[0].play_image)
		end
		id = DeletePlayAfterJob.set(wait: 30.days).perform_later params[:play_id]

		play.update(deleted_flag: true, delete_id: id.provider_job_id)
		render :json => {play_id: play.id, progression_img: progression_img, play_name: play.name}
	end

	def recover_all
		team_id = params[:team_id]
		plays = Play.joins(:team_plays).select("team_plays.team_id as team_id, plays.*").where( "team_plays.team_id"=>params[:team_id], "plays.deleted_flag" => true)
		render_content = []
		plays.each do |play|
			json = Plays::RecoverPlayService.new({
				play_id: play.id
			}).call
			json[:progression_img] = url_for(json[:progression_img])
			render_content.push(json)
		end
		render :json => {content: render_content}
	end

	def recover
		json = Plays::RecoverPlayService.new({
			play_id: params[:play_id]
		}).call
		json[:progression_img] = url_for(json[:progression_img])
		render :json => json
	end

	def destroy_all
		team_id = params[:team_id]
		plays = Play.joins(:team_plays).select("team_plays.team_id as team_id, plays.*").where( "team_plays.team_id"=>params[:team_id], "plays.deleted_flag" => true)
		plays.each do |play|
			Plays::DeletePlayService.new({
				play_id: play.id
			}).call
		end
	end

	def destroy
		Plays::DeletePlayService.new({
			play_id: params[:id]
		}).call

	end

	def demo
	end


	private 

	def verify_member
		curr_member = Member.where("members.user_id" => current_user.id, "members.season_id" => params[:season_id]).take
		if curr_member.nil? && !current_user.admin
			redirect_to root_path
		end
	end

	def verify_team_paid
		season = Season.find_by_id(params[:season_id])
		team = Team.find_by_id(season.team_id)
		if !team.paid
			redirect_to no_access_path
		end
	end

	def authenticate_member
		member = Member.where(user_id: current_user.id, season_id: params[:season_id]).take
		if  current_user.admin 
			@write_permiss = true
			@read_permiss = true
		else
			@write_permiss = member.permissions["plays_edit"]
			@read_permiss = member.permissions["plays_view"]
		end
		
		
	end
end
