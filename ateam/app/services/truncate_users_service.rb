class TruncateUsersService
	def initialize()
	end

	def call()
		ActiveRecord::Base.connection.execute("truncate table users restart identity cascade")
	end
end


