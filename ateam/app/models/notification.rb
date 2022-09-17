class Notification < ApplicationRecord
	belongs_to :notif_type, :polymorphic => true
	belongs_to :season
	has_many :member_notifs
	has_many :members, through: :member_notifs
end
