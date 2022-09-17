module SeasonsHelper
	def get_schedule_event
		if @is_game
			'seasons/show/game_schedule_event'
		elsif @is_practice
			'seasons/show/practice_schedule_event'
		else
			'seasons/show/no_event'
		end
	end
end

