class MyMailer < ApplicationMailer
	def send_join_email(options={})
		@name = options[:name]
		@team_id = options[:team_id].to_s

		@season_id = options[:season_id].to_s
		@member_id = options[:member_id].to_s
		@member_hash = Digest::SHA2.new << @member_id + @name

		season = Season.find_by_id(@season_id)
		@username = season.username
		@password = @member_hash.to_s
		@team_name = season.team_name
		@home_link = "https://ateamsports.app"

	    @email = options[:email]

	    @message = "https://ateamsports.app/teams/" + @team_id + "/seasons/" + @season_id +"/j/"+(@member_hash.to_s)

	    mail(:to=>options[:email], message: @message, :subject=>"Join ATeam Invitation")
	end
end
