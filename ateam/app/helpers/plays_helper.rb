module PlaysHelper
	def plays_partial_path
		if @team_id != nil
			'plays/index/team_plays_index'
		else
			'plays/index/user_plays_index'
		end	
	end

	def play_link_partial_path
		if @team_id != nil
			'plays/plays/team_play'
		else
			'plays/plays/user_play'
		end
	end	

	def plays_home_partial_path

	end

	def show_vs_edit(play_id)
		if @write_permiss
			edit_team_season_play_path(@team_id, @season_id, play_id)
		else
			team_season_play_path(@team_id, @season_id, play_id)
		end
	end

	def play_in_playlist(play_id, playlist_id)
		playlist_assoc = PlaylistAssociation.where(playlist_id: playlist_id)
		playlist_assoc.each do |assoc|
			if assoc.play_id == play_id
				return false
			end
		end
	end
end
