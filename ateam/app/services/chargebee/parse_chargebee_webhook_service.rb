class Chargebee::ParseChargebeeWebhookService
	def initialize(params)
		@info = params[:info]
		@event_type = params[:event_type]
	end

	def call()
		case @event_type
		when "subscription_created"
			response = subscription_created
		when "subscription_activated"
			response = subscription_activated
		when "subscription_cancelled"
			response = subscription_cancelled
		when "subscription_reactivated"
			response = subscription_reactivated
		when "subscription_paused"
			response = subscription_paused
		when "subscription_resumed"
			response = subscription_resumed
		when "payment_failed"
			response = payment_failed
		end
		return response
	end

	private 

	def subscription_created
		return @event_type
	end

	def subscription_activated
		return @event_type
	end

	def subscription_cancelled
		customer_id = @info["subscription"]["customer_id"]
		user = User.where(customer_id: customer_id).take
		team = Team.where(user_id: user.id).take
     	team.update(paid: false)
		return @event_type
	end

	def subscription_reactivated
	    customer_id = @info["subscription"]["customer_id"]
		user = User.where(customer_id: customer_id).take
		team = Team.where(user_id: user.id).take
     	team.update(paid: true)
		return @event_type
	end

	def subscription_paused
		return @event_type
	end

	def subscription_resumed
		return @event_type
	end

	def payment_failed
		return @event_type
	end
end