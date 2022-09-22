
class AdminController < ApplicationController
	def index
		@small_header = true
	    if current_user.admin
	        if cookies[:season_id].present?
	            @season = Season.find_by_id(cookies[:season_id])
	        end
	        @seasons = Season.joins(team: :user).select("seasons.*, seasons.id as season_id, users.*, teams.*").all
	        @teams = Team.joins(:user).select("teams.*, teams.id as team_id, users.*").all
	        @users = User.all
	    else
	        redirect_to root_path
	    end
	end

	def mailer
		@small_header = true
	    if current_user.admin

	    else
	        redirect_to root_path
	    end
	end

	def read_excel_file
		data = Roo::Spreadsheet.open('lib/data.xlsx')
		headers = data.row(1) # get header row
		data.each_with_index do |row, idx|
		  next if idx == 0 # skip header
		  # create hash from headers and cells
		  user_data = Hash[[headers, row].transpose]
		  puts user_data
		end
	end

	def send_mail
		# puts params
		coaches = params["emails"]
		response = []
		coaches.each do |coach_info|
			coach_info = coach_info[1]
			coach_name = coach_info["Name"]
			email = coach_info["Email"]
			puts "*******************"
			puts coach_name
			puts email
			puts "*******************"
			validate = Truemail.validate(email, with: :smtp)
			MarketingMailer.marketing_email(name: coach_name, email: email).deliver
			send_bool = true
			# puts validate.result
			# if validate.result.success
			# 	if validate.result.smtp_debug
			# 		puts "****"
			# 		puts validate.result.smtp_debug
			# 		if validate.result.smtp_debug[0].response
			# 			puts "****"
			# 			puts validate.result.smtp_debug[0].response
			# 			if validate.result.smtp_debug[0].response.errors && validate.result.smtp_debug[0].response.errors.length > 0
			# 				send_bool = false
			# 			end
			# 		end
			# 	end
			# 	if send_bool
			# 		puts "SUCCESS"
			# 		# MarketingMailer.marketing_email(name: coach_name, email: email).deliver
			# 	else
			# 		response.push({coach: coach_name, email: email})
			# 		puts "smtp error"
			# 	end
			# else
			# 	response.push({coach: coach_name, email: email})
			# 	puts "Failed :/"
			# end

		end
		# render :json => {response: response}
	end
end
