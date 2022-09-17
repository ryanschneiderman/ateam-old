class MarketingMailer < ApplicationMailer
	def marketing_email(options={})
		@name = options[:name]

	    @email = options[:email]

	    @message = "Test"

	    headers['X-SES-CONFIGURATION-SET'] = 'email-opens'

	    mail( from: 'Ryan Schneiderman <ryan@ateamsports.awsapps.com>', :to=>options[:email], name: @name, :subject=>"Basketball Coaching Tool")
	end
end