
class Plays::RecoverPlayService
	def initialize(params)
		@play_id = params[:play_id]
	end

	def call()
		play = Play.joins(:team_plays, :play_views).select("team_plays.team_id as team_id, play_views.member_id as member_id, play_views.viewed as viewed, plays.*").where("plays.id" => @play_id).take
		# play = Play.find_by_id(@play_id)
		puts "****play.delete_id****"
		puts play.delete_id

		list = Sidekiq::ScheduledSet.new
		jobs = list.select{|job| job.jid == play.delete_id }

		jobs.each(&:delete)

		play.update(deleted_flag: false, delete_id: nil)

		progression = Progression.where(play_id: play.id)
		progression_img = progression[0].play_image
		return {play: play, progression_img: progression_img,}
	end
end