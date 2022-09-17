class UsersController < ApplicationController
	skip_before_action :authenticate_user!, only: [:verify_email_unique]
	def get_seasons
		seasons = Season.joins(:members).select("seasons.* , members.user_id as user_id").where("members.user_id" => current_user.id).sort_by{|e| e.id}
		render :json => {seasons: seasons}
	end

	def verify_email_unique
		user = User.where(email: params[:email]).take
		if user.nil?
			render :json => {unique: true}
		else
			render :json => {unique: false}
		end
	end

	def destroy_user
		User.find_by_id(params[:user_id]).destroy
		redirect_to admin_path
	end

	def make_user_admin
		if(current_user.admin)
			user = User.find_by_id(params[:user_id])
			user.update(admin: true)
			redirect_to admin_path
		end
	end
end
