class NotificationsController < ApplicationController
	def viewed
		notifications = params[:notifications]
		if notifications 
			notifications.each do |notif|
				viewed_notif = MemberNotif.find_by_id(notif[1][:id])
				viewed_notif.update(viewed: true)
			end
		end
	end

	def read
		notification_id = params[:notification_id]
		notif = MemberNotif.find_by_id(notification_id)
		notif.update(read: true)
	end


	def load_more_notifications
		members = Member.where(user_id: current_user.id)
		mem_ids = []
		members.each do |mem|
			mem_ids.push(mem.id)
		end
		page = params[:page]
		notification_objs = []
		notifications = Notification.joins(:member_notifs).select("notifications.*, member_notifs.member_id, member_notifs.viewed, member_notifs.read as read, member_notifs.id as member_notif_id").where("member_notifs.member_id" => mem_ids).paginate(page: page, per_page:10).order('created_at DESC')
		notifications.each do |notif|
			notification_objs.push({notif: notif, time_ago: time_ago_in_words(notif.updated_at), link: polymorphic_url([Team.find_by_id(notif.team_id), Season.find_by_id(notif.season_id), notif.notif_type_type.tableize.singularize], :id => notif.notif_type_id)})
		end

		render :json => {notifications: notification_objs}
	end
end
