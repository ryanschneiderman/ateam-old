module NavigationHelper

  def collapsible_links_partial_path(small_header)
    if user_signed_in?
    	# query all teams that a user belongs to --> query all members associated with the user
    	member = Member.find_by(user_id: current_user.id)
      season_id = cookies[:season_id]

    	if member.nil? || season_id.blank?
    		if small_header
    			'layouts/navigation/collapsible_elements/alt_signed_in_links'
    		else
      			'layouts/navigation/collapsible_elements/signed_in_links'
      		end
      	else
      		'layouts/navigation/collapsible_elements/team_signed_in_links'
      	end
    else
    	if small_header
    		## alt_signed_in_links same when non signed in
    		'layouts/navigation/collapsible_elements/alt_signed_in_links'
    	else
     		'layouts/navigation/collapsible_elements/non_signed_in_links'
     	end
    end
  end

  def slide_out_area_path
    if user_signed_in?
      # query all teams that a user belongs to --> query all members associated with the user
      member = Member.find_by(user_id: current_user.id)
      season_id = cookies[:season_id]
      if member.nil? || season_id.blank?
          'layouts/slide_out_menu/signed_in_slide_out'
        else
          'layouts/slide_out_menu/team_slide_out'
        end
    else
      'layouts/slide_out_menu/non_signed_in_slide_out'
    end
  end

  def header_extras_path
  	if user_signed_in?
  		# query all teams that a user belongs to --> query all members associated with the user
  		member = Member.find_by(user_id: current_user.id)
      season_id = cookies[:season_id]
  		if member.nil? || season_id.blank?
  	  		'layouts/header_extras'
  	  	else
  	  		'layouts/team_header_extras'
  	  	end
  	else
  		'layouts/non_user_header_extras'
  	end
  end

	def conversation_header_partial_path(conversation)
	  if conversation.class == Private::Conversation
	    'layouts/navigation/header/dropdowns/conversations/private'
	  else
	    'layouts/navigation/header/dropdowns/conversations/group'
	  end  
	end

	def nav_header_left_partials
	    partials = []
	    if params[:controller] == 'messengers' 
	      partials << 'layouts/navigation/header/messenger_header'
	    else # controller is not messengers  
	      partials << 'layouts/navigation/header/home_button'
	      partials << 'layouts/navigation/header/toggle_button'
	    end
	    partials
	end

	def get_team_name(team_id)
		team = Team.find_by_id(team_id)
		team.name
	end


  
end