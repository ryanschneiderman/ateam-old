module SettingsHelper
	def settings_permission_path(read, write)
		if write
	      'settings/settings'
	    elsif read
	      'settings/settings_read'
	  	else
	  	  'settings_not_permitted'
	    end
	end
end
