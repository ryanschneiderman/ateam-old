class Seeds::Senders::SendTeamGameLogDataService
	def initialize(params)
		@season_id = params[:season_id]
		@team_id = params[:team_id]
	end

	def call
		url_base = 'https://stats.nba.com/stats/teamgamelog'

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
			LeagueID: '00',
			SeasonType: 'Regular Season',
			TeamID: 1610612738,
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
		RestClient.post 'https://ateamsports.app/seeding_endpoint', {data: {json: json, season_id: 1, team_id: 1}, data_kind: "team_game_log"}.to_json, {content_type: :json, accept: :json}
		
	end



end





