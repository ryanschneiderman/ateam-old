require 'action_view'
require 'action_dispatch'
include ActionView::Helpers::DateHelper
include ActionView::Helpers::UrlHelper
include ActionDispatch::Routing::PolymorphicRoutes
class ApplicationController < ActionController::Base
	before_action :opened_conversations_windows
	before_action :all_ordered_conversations
	before_action :set_user_data
	before_action :all_related_members
	before_action :authenticate_user!
	before_action :notifications
	before_action :gon_user_data
	before_action :set_cookie_data
	before_action :set_team_season_vars

	def opened_conversations_windows
	  if user_signed_in?
	    # opened conversations
	    session[:private_conversations] ||= []
	    session[:group_conversations] ||= []
	    @private_conversations_windows = Private::Conversation.includes(:recipient, :messages)
	                                         .find(session[:private_conversations])
	    @group_conversations_windows = Group::Conversation.find(session[:group_conversations])
	  else
	    @private_conversations_windows = []
	    @group_conversations_windows = []
	  end
	end

	def all_ordered_conversations 
	  if user_signed_in?
	    @all_conversations = OrderConversationsService.new({user: current_user}).call
	  end
	end 

	## try to condense into one query
	def all_related_members
		if user_signed_in?
			# @all_related_members = []
			# teams_belonging_to_user = Team.joins(:members).where(members: {user_id: current_user.id})
			# teams_belonging_to_user.each do |team|
			# 	members = Member.where(team_id: team.id)
			# 	members.each do |member|
			# 		if member.user_id != current_user.id
			# 			@all_related_members.push(User.find_by_id(member.user_id))
			# 		end
			# 	end
			# end
		end
	end

	def notifications
		if user_signed_in?
			members = Member.where(user_id: current_user.id)
			mem_ids = []
			members.each do |mem|

				mem_ids.push(mem.id)
			end
			@notification_objs = []
			@notifications = Season.joins(notifications: :member_notifs).select("notifications.*,  member_notifs.member_id, seasons.team_id as team_id, member_notifs.viewed, member_notifs.read as read, member_notifs.id as member_notif_id").where("member_notifs.member_id" => mem_ids).paginate(page: 1, per_page:10).order('created_at DESC')
			# @notifications = Notification.joins(:member_notifs).select("notifications.*,  member_notifs.member_id, member_notifs.viewed, member_notifs.read as read, member_notifs.id as member_notif_id").where("member_notifs.member_id" => mem_ids).paginate(page: 1, per_page:10).order('created_at DESC')
			@notifications.each do |notif|
				@notification_objs.push({notif: notif, time_ago: time_ago_in_words(notif.updated_at), link: polymorphic_url([Team.find_by_id(notif.team_id), Season.find_by_id(notif.season_id), notif.notif_type_type.tableize.singularize], :id => notif.notif_type_id)})
			end
			gon.notifications = @notification_objs
		end
	end

	def gon_user_data
		gon.current_user = current_user
	end


	def set_user_data
	  if user_signed_in?
	    gon.group_conversations = current_user.group_conversations.ids
	    gon.user_id = current_user.id
	    cookies[:user_id] = current_user.id if current_user.present?
	    cookies[:group_conversations] = current_user.group_conversations.ids
	  else
	    gon.group_conversations = []
	  end
	end

	def set_cookie_data
		if params[:team_id].present?
			cookies[:team_id] = params[:team_id]
		end
		if params[:season_id].present?
			cookies[:season_id] = params[:season_id]
		end
	end

	def set_team_season_vars
		if cookies[:team_id].present?
			@team_id = cookies[:team_id]
		end
		if cookies[:season_id].present?
			@season_id = cookies[:season_id]
			@season = Season.find_by_id(@season_id)
		end
	end


end
