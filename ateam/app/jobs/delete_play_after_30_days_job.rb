class DeletePlayAfter30DaysJob < ApplicationJob
  queue_as :default

  def perform(play_id)
    Plays::DeletePlayService.new({
		play_id: play_id
	}).call
  end
end
