class InsertPlayTypesService
	def initialize()
	end

	def call()
		PlayType.create(
			play_type: "Halfcourt"
		)

		PlayType.create(
			play_type: "Fullcourt"
		)
	end
end