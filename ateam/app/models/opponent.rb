class Opponent < ApplicationRecord
	belongs_to :team
	has_many :stats  
	has_many :opponent_granules
	has_many :games
end
