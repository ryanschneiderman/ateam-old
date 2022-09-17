class DeletePlayAfterJob < ApplicationJob
  queue_as :default

  def perform(play_id)
  	puts "EXECUTING JOB"
    Plays::DeletePlayService.new({
		play_id: play_id
	}).call
  end
end
