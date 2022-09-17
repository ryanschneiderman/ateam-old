class ProductController < ApplicationController
	skip_before_action :authenticate_user!, only: [:index, :play_diagramming, :stat_collection, :analytics, :team_hub]
	def index
		@small_header = true
		if cookies[:season_id].present?
	        @season = Season.find_by_id(cookies[:season_id])
	    end
	end

	def play_diagramming
		@small_header = true
		if cookies[:season_id].present?
	        @season = Season.find_by_id(cookies[:season_id])
	    end
	end

	def stat_collection
		@small_header = true
		if cookies[:season_id].present?
	        @season = Season.find_by_id(cookies[:season_id])
	    end
	end

	def analytics
		@small_header = true
		if cookies[:season_id].present?
	        @season = Season.find_by_id(cookies[:season_id])
	    end
	end

	def team_hub
		@small_header = true
		if cookies[:season_id].present?
	        @season = Season.find_by_id(cookies[:season_id])
	    end
	end
end
