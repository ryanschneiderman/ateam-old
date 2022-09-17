class InsertRolesService
	def initialize()
	end

	def call()
		Role.create(
			name: "Player"
		)

		Role.create(
			name: "Coach"
		)

		Role.create(
			name: "Manager"
		)

		Role.create(
			name: "Owner"
		)
		Role.create(
			name: "Other"
		)

		Sport.create(
			name: "Basketball"
		)

	end
end

