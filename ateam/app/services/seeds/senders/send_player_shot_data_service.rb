class Seeds::Senders::SendPlayerShotDataService
  def initialize(params)
    @player_id = params[:player_id]
    @member_id = params[:member_id]
    @season_id = params[:season_id]
  end

  def call
  	url_base = 'https://stats.nba.com/stats/shotchartdetail'

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
      ContextMeasure: 'FGA',
      LastNGames: 0,
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
      GameID: '',
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
      puts "PRINTING GAME"

      shot_chart_data = []
      stat_granule_hash = []
      game = Game.where(season_id: @season_id).take
      player_obj = {}
      json["resultSets"][0]["rowSet"].each do |shot_data|
        shot_obj = {}
        i = 0
        shot_data.each do |data_point|
          #puts single_point
          shot_obj.merge!({json["resultSets"][0]["headers"][i] => data_point})
          i+=1
        end
        #puts shot_obj
        if shot_obj["EVENT_TYPE"] == "Made Shot"
          shot_result = 1
        else
          shot_result = 2
        end
        # puts shot_obj["GAME_ID"]
        # puts shot_obj
        if shot_obj["GAME_DATE"] == "20200811"
          puts shot_obj
        shot_chart_data.append(shot_obj)
        stat_granule_hash.push({
          metadata: {"x_loc" => "#{(shot_obj['LOC_X']+267).to_f / 530}", "y_loc" => "#{(shot_obj['LOC_Y']+52).to_f / 580}"},
            member_id: @member_id,
            game_id: 2425,
            stat_list_id: shot_result,
            season_id: @season_id
        })
        end
      end
      StatGranule.import stat_granule_hash

      

  end

  private 




end





