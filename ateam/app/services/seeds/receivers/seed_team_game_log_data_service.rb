class Seeds::Receivers::SeedTeamGameLogDataService
	def initialize(params)
		@season_id = params[:data][:season_id]
		@team_id = params[:data][:team_id]
		@json = params[:data][:json]
	end

	def call
		json = @json
		stat_hash = []
		game_log_chart_data = []
		player_obj = {}
		json["resultSets"][0]["rowSet"].each do |game_data|
			game_obj = {}
			i = 0
			game_data.each do |data_point|
				game_obj.merge!({json["resultSets"][0]["headers"][i] => data_point})
				i+=1
			end
			stat_hash = create_stats(game_obj, stat_hash)
			puts game_obj
		end
		StatTotal.import stat_hash
	end


	private 

	def create_stats (game_obj, stat_hash)
		opp_name = game_obj["MATCHUP"].split[2]
		schedule_event = ScheduleEvent.where(name: opp_name + game_obj["Game_ID"], team_id: @team_id).take
		if schedule_event.nil?
			date_str = game_obj["GAME_DATE"].split
			month = get_month(date_str[0])
			year = date_str[2].to_i
			day = (date_str[1].chop).to_i
			schedule_event = ScheduleEvent.create(
				date: DateTime.new(year, month, day),
				name: opp_name + game_obj["Game_ID"],
				team_id: @team_id,
			)

			opp = Opponent.create(name: opp_name, team_id: @team_id)

			game = Game.new(team_id: @team_id, played: true, schedule_event_id: schedule_event.id, season_id: @season_id, opponent_id: opp.id)
			game.save!
		else
			game = Game.where(schedule_event_id: schedule_event.id).take
		end
		
		stat_hash.push({
			value: game_obj["FGM"],
			stat_list_id: 1,
			game_id: game.id,
			season_id: @season_id,
			team_id: @team_id,
			is_opponent: false
		})

		stat_hash.push({
			value: game_obj["FGA"] - game_obj["FGM"],
			stat_list_id: 2,
			game_id: game.id,
			season_id: @season_id,
			team_id: @team_id,
			is_opponent: false
		})


		stat_hash.push({
			value: game_obj["AST"],
			stat_list_id: 3,
			game_id: game.id,
			season_id: @season_id,
			team_id: @team_id,
			is_opponent: false
		})


		stat_hash.push({
			value: game_obj["OREB"],
			stat_list_id: 4,
			game_id: game.id,
			season_id: @season_id,
			team_id: @team_id,
			is_opponent: false
		})


		stat_hash.push({
			value: game_obj["DREB"],
			stat_list_id: 5,
			game_id: game.id,
			season_id: @season_id,
			team_id: @team_id,
			is_opponent: false
		})


		stat_hash.push({
			value: game_obj["STL"],
			stat_list_id: 6,
			game_id: game.id,
			season_id: @season_id,
			team_id: @team_id,
			is_opponent: false
		})


		stat_hash.push({
			value: game_obj["TOV"],
			stat_list_id: 7,
			game_id: game.id,
			season_id: @season_id,
			team_id: @team_id,
			is_opponent: false
		})

		stat_hash.push({
			value: game_obj["BLK"],
			stat_list_id: 8,
			game_id: game.id,
			season_id: @season_id,
			team_id: @team_id,
			is_opponent: false
		})

		stat_hash.push({
			value: game_obj["FG3M"],
			stat_list_id: 11,
			game_id: game.id,
			season_id: @season_id,
			team_id: @team_id,
			is_opponent: false
		})

		stat_hash.push({
			value: game_obj["FG3A"] - game_obj["FG3M"],
			stat_list_id: 12,
			game_id: game.id,
			season_id: @season_id,
			team_id: @team_id,
			is_opponent: false
		})

		stat_hash.push({
			value: game_obj["FTM"],
			stat_list_id: 13,
			game_id: game.id,
			season_id: @season_id,
			team_id: @team_id,
			is_opponent: false
		})

		stat_hash.push({
			value: game_obj["FTA"] - game_obj["FTM"],
			stat_list_id: 14,
			game_id: game.id,
			season_id: @season_id,
			team_id: @team_id,
			is_opponent: false
		})

		stat_hash.push({
			value: game_obj["PTS"],
			stat_list_id: 15,
			game_id: game.id,
			season_id: @season_id,
			team_id: @team_id,
			is_opponent: false
		})

		stat_hash.push({
			value: game_obj["MIN"] * 60,
			stat_list_id: 16,
			game_id: game.id,
			season_id: @season_id,
			team_id: @team_id,
			is_opponent: false
		})

		stat_hash.push({
			value: game_obj["PF"],
			stat_list_id: 17,
			game_id: game.id,
			season_id: @season_id,
			team_id: @team_id,
			is_opponent: false
		})

		stat_hash.push({
			value: game_obj["FGA"],
			stat_list_id: 47,
			game_id: game.id,
			season_id: @season_id,
			team_id: @team_id,
			is_opponent: false
		})

		stat_hash.push({
			value: game_obj["FG3A"],
			stat_list_id: 48,
			game_id: game.id,
			season_id: @season_id,
			team_id: @team_id,
			is_opponent: false
		})

		stat_hash.push({
			value: game_obj["FTA"],
			stat_list_id: 49,
			game_id: game.id,
			season_id: @season_id,
			team_id: @team_id,
			is_opponent: false
		})

		stat_hash.push({
			value: game_obj["FG_PCT"],
			stat_list_id: 26,
			game_id: game.id,
			season_id: @season_id,
			team_id: @team_id,
			is_opponent: false
		})

		stat_hash.push({
			value: game_obj["FG3_PCT"],
			stat_list_id: 27,
			game_id: game.id,
			season_id: @season_id,
			team_id: @team_id,
			is_opponent: false
		})

		stat_hash.push({
			value: game_obj["FT_PCT"],
			stat_list_id: 28,
			game_id: game.id,
			season_id: @season_id,
			team_id: @team_id,
			is_opponent: false
		})
	end

	def get_month(str)
		case str 
		when "JAN"
			return 1
		when "FEB"
			return 2
		when "MAR"
			return 3
		when "APR"
			return 4
		when "MAY"
			return 5
		when "JUN"
			return 6
		when "JUL"
			return 7
		when "AUG"
			return 8
		when "SEP"
			return 9
		when "OCT"
			return 10
		when "NOV"
			return 11
		when "DEC"
			return 12
		end
	end


end





