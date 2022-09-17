class Seeds::Receivers::SeedTeamSeasonStatService
	def initialize(params)
		@member_id = params[:member_id]
		@player_id = params[:player_id]
	end

	def call
		url_base = 'https://stats.nba.com/stats/playerfantasyprofile'

		headers = {
				accept: "application/json, text/plain, */*",
				accept_language: "en-US,en;q=0.8",
				cache_control: "no-cache",
				connection: "keep-alive",
				host: "stats.nba.com",
				pragma: "no-cache",
				x_nba_stats_origin: "stats",
				x_nba_stats_token: "true",
				referer: "https://stats.nba.com/",
				upgrade_insecure_requests: "1",
				user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9"
		}



		parameters = {
			MeasureType: 'Base',
			PaceAdjust: 'N',
			PerMode: 'Totals',
			PlusMinus: 'N',
			Rank: 'N',
			LeagueID: '00',
			PlayerID: @player_id,
			SeasonType: 'Regular Season',
			Season: '2019-20',
		}

		request = RestClient::Request.execute(
			method: :get,
			url: url_base,
			headers: headers.merge(params: parameters),
			timeout: 5
		)

		request_body = request.body


		json = JSON.parse(request_body)
		puts json
		stat_obj = {}
		stat_hash = []
		stats = json["resultSets"][0]["rowSet"][0]
		i = 0
		stats.each do |data_point|
			stat_obj.merge!({json["resultSets"][0]["headers"][i] => data_point})
			i+=1
		end

		stat_hash = create_stats(stat_obj, stat_hash)
		SeasonStat.import stat_hash
		member = Member.find_by_id(@member_id)
		member.season_minutes = stat_obj["MIN"] * 60
		member.games_played = stat_obj["GP"]
		member.save!
	end


	private 

	def create_stats (stat_obj, stat_hash)
		
		stat_hash.push({
			value: stat_obj["FGM"],
			stat_list_id: 1,
			member_id: @member_id,
			season_id: 1
		})

		stat_hash.push({
			value: stat_obj["FGA"] - stat_obj["FGM"],
			stat_list_id: 2,
			member_id: @member_id,
			season_id: 1
		})


		stat_hash.push({
			value: stat_obj["AST"],
			stat_list_id: 3,
			member_id: @member_id,
			season_id: 1
		})


		stat_hash.push({
			value: stat_obj["OREB"],
			stat_list_id: 4,
			member_id: @member_id,
			season_id: 1
		})


		stat_hash.push({
			value: stat_obj["DREB"],
			stat_list_id: 5,
			member_id: @member_id,
			season_id: 1
		})


		stat_hash.push({
			value: stat_obj["STL"],
			stat_list_id: 6,
			member_id: @member_id,
			season_id: 1
		})


		stat_hash.push({
			value: stat_obj["TOV"],
			stat_list_id: 7,
			member_id: @member_id,
			season_id: 1
		})

		stat_hash.push({
			value: stat_obj["BLK"],
			stat_list_id: 8,
			member_id: @member_id,
			season_id: 1
		})

		stat_hash.push({
			value: stat_obj["FG3M"],
			stat_list_id: 11,
			member_id: @member_id,
			season_id: 1
		})

		stat_hash.push({
			value: stat_obj["FG3A"] - stat_obj["FG3M"],
			stat_list_id: 12,
			member_id: @member_id,
			season_id: 1
		})

		stat_hash.push({
			value: stat_obj["FTM"],
			stat_list_id: 13,
			member_id: @member_id,
			season_id: 1
		})

		stat_hash.push({
			value: stat_obj["FTA"] - stat_obj["FTM"],
			stat_list_id: 14,
			member_id: @member_id,
			season_id: 1
		})

		stat_hash.push({
			value: stat_obj["PTS"],
			stat_list_id: 15,
			member_id: @member_id,
			season_id: 1
		})

		stat_hash.push({
			value: stat_obj["MIN"] * 60,
			stat_list_id: 16,
			member_id: @member_id,
			season_id: 1
		})

		stat_hash.push({
			value: stat_obj["PF"],
			stat_list_id: 17,
			member_id: @member_id,
			season_id: 1
		})

		stat_hash.push({
			value: stat_obj["FGA"],
			stat_list_id: 47,
			member_id: @member_id,
			season_id: 1
		})

		stat_hash.push({
			value: stat_obj["FG3A"],
			stat_list_id: 48,
			member_id: @member_id,
			season_id: 1
		})

		stat_hash.push({
			value: stat_obj["FTA"],
			stat_list_id: 49,
			member_id: @member_id,
			season_id: 1
		})

		stat_hash.push({
			value: stat_obj["FG_PCT"],
			stat_list_id: 26,
			member_id: @member_id,
			season_id: 1
		})

		stat_hash.push({
			value: stat_obj["FG3_PCT"],
			stat_list_id: 27,
			member_id: @member_id,
			season_id: 1
		})

		stat_hash.push({
			value: stat_obj["FT_PCT"],
			stat_list_id: 28,
			member_id: @member_id,
			season_id: 1
		})
	end




end





