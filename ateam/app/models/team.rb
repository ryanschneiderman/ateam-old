class Team < ApplicationRecord
	has_many :team_plays
	has_many :opponents
	has_many :playlists
	belongs_to :sport
	belongs_to :user
	has_many :seasons
end
