class Seeds::Receivers::SeedShotDataService
  def initialize(params)
    @team_id = params[:data][:team_id]
    @season_id = params[:data][:season_id]
    @member_id = params[:data][:member_id]
    @json = params[:data][:json]
  end

  def call
      json = @json
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
        shot_chart_data.append(shot_obj)
        stat_granule_hash.push({
          metadata: {"x_loc" => "#{(shot_obj['LOC_X']+267).to_f / 530}", "y_loc" => "#{(shot_obj['LOC_Y']+52).to_f / 580}"},
            member_id: @member_id,
            game_id: game.id,
            stat_list_id: shot_result,
            season_id: @season_id
        })
      end
      StatGranule.import stat_granule_hash
  end

  private 




end





