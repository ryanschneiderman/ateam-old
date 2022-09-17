class Seeds::Senders::SendGameLogDataService
	def initialize(params)
		@player_id = params[:player_id]
		@member_id = params[:member_id]
	end

	def call
		url_base = 'https://stats.nba.com/stats/playergamelog'

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
			LastNGames: 15,
			LeagueID: '00',
			Month: 0,
			OpponentTeamID: 0,
			Period: 0,
			PlayerID: @player_id,
			SeasonType: 'Regular Season',
			TeamID: 0,
			VsDivision: '',
			VsConference: '',
			SeasonSegment: '',
			Season: '2019-20',
			RookieYear: '',
			PlayerPosition: '',
			Outcome: '',
			Location: '',
			GameSegment: '',
			GameId: '',
			DateTo: '',
			DateFrom: ''
		}

		request = RestClient::Request.execute(
			method: :get,
			url: url_base,
			headers: headers.merge(params: parameters),
			timeout: 5
		)

		request_body = request.body


		json = JSON.parse(request_body)

		RestClient.post 'https://ateamsports.app/seeding_endpoint', {data: {json: json, season_id: 1, team_id: 1, member_id: @member_id}, data_kind: "player_game_log"}.to_json, {content_type: :json, accept: :json}

	end




end





