class TruncateTeamsService
	def initialize()
	end

	def call()
		ActiveRecord::Base.connection.execute("truncate table seasons restart identity")
		ActiveRecord::Base.connection.execute("truncate table teams restart identity")
		ActiveRecord::Base.connection.execute("truncate table members restart identity cascade")
		ActiveRecord::Base.connection.execute("truncate table team_stats restart identity")
		ActiveRecord::Base.connection.execute("truncate table playlists restart identity")
		ActiveRecord::Base.connection.execute("truncate table plays restart identity")
	end
end


