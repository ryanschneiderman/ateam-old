class ScheduleEvent < ApplicationRecord
	has_one :game
	belongs_to :season
	has_one :practice
	has_many :posts, :as => :post_type
	has_many :notifications, :as => :notif_type
end
