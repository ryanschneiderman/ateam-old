
class DemosController < ApplicationController
	skip_before_action :authenticate_user!, only: [:index, :plays, :analytics, :game_mode]

  def index
    @small_header = true
    if cookies[:season_id].present?
        @season = Season.find_by_id(cookies[:season_id])
    end
  end

  def analytics
    user = User.where(front_page: true).take
    @team = Team.where(user_id: user.id).take
    @team_id = @team.id
    @small_header = true
    #@team_name = @team.name
    
    @season = Season.where(team_id: @team_id).take

    @season_id = @season.id
    @team_name = @season.team_name
    gon.team_id = @team_id
    
    @per_minutes = @season.num_periods * @season.period_length * 3 / 4

    stat_lists = StatList.all
    gon.stat_lists = stat_lists


    @players = Member.where(is_player: true, season_id: @season_id)

    @num_games = Game.where(played: true, season_id: @season_id).count

    @opponent_name = "Opponents"



    @stat_table_columns = Stats::BasicStatService.new({
      season_id: @season_id
    }).call
    @stat_table_columns = @stat_table_columns.sort_by{|e| [e[:stat_kind], e[:display_priority]]}


    @adv_stat_table_columns = Stats::Advanced::AdvancedStatListService.new({
      season_id: @season_id
    }).call


    @team_adv_stat_table_columns = Stats::Advanced::TeamAdvancedStatListService.new({
      season_id: @season_id
    }).call

    ## player stats
    @player_stats = []

    player_stats_ungrouped = SeasonStat.joins(:stat_list, :member).select("members.games_played as games_played, members.season_minutes as season_minutes, stat_lists.stat as stat, members.nickname as nickname, stat_lists.display_priority as display_priority, season_stats.*").where("season_stats.season_id" => @season_id).sort_by{|e| [e.member_id, e.stat_list_id]}
    player_stats_ungrouped.group_by(&:member_id).each do |member_id, stats|
      @player_stats.push({member_id: member_id, stats: stats, nickname: stats[0].nickname, games_played: stats[0].games_played, minutes: stats[0].season_minutes})
    end

    @advanced_stats = []
    advanced_stats_ungrouped = SeasonAdvancedStat.joins(:stat_list, :member).select("members.games_played as games_played, members.season_minutes as season_minutes, stat_lists.stat as stat, members.nickname as nickname, stat_lists.stat_description as stat_description, stat_lists.display_priority as display_priority, season_advanced_stats.*").where("season_advanced_stats.season_id" => @season_id).sort_by{|e| [e.member_id, e.stat_list_id]}
    advanced_stats_ungrouped.group_by(&:member_id).each do |member_id, stats|
      @advanced_stats.push({member_id: member_id, stats: stats, nickname: stats[0].nickname, games_played: stats[0].games_played, minutes: stats[0].season_minutes})
    end

    @team_stats = TeamSeasonStat.select("*").joins(:stat_list).where(is_opponent: false, season_id: @season_id)

    @opponent_stats = TeamSeasonStat.select("*").joins(:stat_list).where(is_opponent: true, season_id: @season_id)

    @team_advanced_stats = SeasonTeamAdvStat.select("*").joins(:stat_list).where(season_id: @season_id)


    opponent_shot_chart_data = OpponentGranule.joins(:opponent).select("opponent_granules.*").where("opponent_granules.season_id" => @season_id, "opponent_granules.stat_list_id"=> [1,2])

    @lineups = Lineup.where(season_id: @season_id)
    
    @members = Member.where(is_player: true, season_id: @season_id)

    gon.lineup_objs = StatsIndex::LineupStatsService.new({team_id: @team_id, season_id: @season_id, sorting_stat: 16, page: 1}).call

    @team_points = StatTotal.joins([:stat_list, {:game => :opponent}, {:game => :schedule_event}]).select("schedule_events.date as date, stat_lists.stat as stat, opponents.name as opponent_name, stat_totals.*").where("stat_lists.team_stat" => false, "stat_totals.is_opponent" => false,  "stat_lists.rankable" => true, "stat_lists.id" => 15, "stat_totals.season_id" => @season_id).sort_by{|e| [e.stat_list_id, e.date]}
    gon.team_points = @team_points;

    #@stat_totals = StatTotal.joins(:stat_list).joins(:game => :schedule_event).select("schedule_events.date as date, stat_lists.stat as stat, stat_totals.*").where("stat_lists.team_stat" => false, "stat_totals.team_id" => @team.id, "stat_totals.is_opponent" => false, "stat_lists.rankable" => true).sort_by{|e| [e.stat_list_id, e.date]}
    @trend_stat_lists = TeamStat.joins(:stat_list).select("stat_lists.stat as stat, team_stats.*").where("team_stats.season_id" => @season_id, "stat_lists.team_stat" => false, "stat_lists.rankable" => true, "stat_lists.advanced" => false).sort_by{|e| e.stat_list_id}


    @off_stat_lists = TeamStat.joins(:stat_list).select("stat_lists.stat as stat, team_stats.*").where("team_stats.season_id" => @season_id, "stat_lists.team_stat" => false, "stat_lists.rankable" => true, "stat_lists.advanced" => false, "stat_lists.stat_kind" => 1).sort_by{|e| e.stat_list_id}

    @def_stat_lists = TeamStat.joins(:stat_list).select("stat_lists.stat as stat, team_stats.*").where("team_stats.season_id" => @season_id, "stat_lists.team_stat" => false, "stat_lists.rankable" => true, "stat_lists.advanced" => false, "stat_lists.stat_kind" => 2).sort_by{|e| e.stat_list_id}
    gon.stats_demo = true
    gon.season_id = @season_id
    gon.team_name = @team_name
    gon.team_id = @team_id
    gon.num_players = @players.length
    gon.minutes_factor = @per_minutes
    gon.stat_table_columns = @stat_table_columns
    gon.adv_stat_table_columns = @adv_stat_table_columns
    gon.team_adv_stat_table_columns = @team_adv_stat_table_columns
    gon.player_stats = @player_stats
    gon.advanced_stats = @advanced_stats
    gon.team_stats= @team_stats
    gon.opponent_stats = @opponent_stats
    gon.team_advanced_stats = @team_advanced_stats
    gon.shot_chart_data = @shot_chart_data
    gon.opponent_shot_chart_data = opponent_shot_chart_data
    gon.off_stat_lists = @off_stat_lists
    gon.def_stat_lists = @def_stat_lists
  end

  def game_mode
    user = User.where(front_page: true).take
    @team = Team.where(user_id: user.id).take
    @team_id = @team.id
    @small_header = true
    #@team_name = @team.name
    
    @season = Season.where(team_id: @team_id).take
    @season_id = @season.id
    @team_name = @season.team_name
    gon.team_id = @team_id

    gon.team_name = @season.team_name
    @team_name = @season.team_name

    gon.current_user = current_user

    @players = Member.where(season_id: @season_id, is_player: true)
    gon.players = @players

    @opponent_name = "Miami Heat"
    @opponent_id = 0;
    gon.opponent_id = @opponent_id
    gon.opponent_name = @opponent_name
    gon.current_member_nickname = "Assistant"

    # @opponent = Opponent.find_by_id(game.opponent_id)
    # gon.opponent = @opponent

    team_stats = TeamStat.where(season_id: @season_id)


    @per_minutes = @season.period_length 
    gon.num_periods = @season.num_periods
    gon.period_length = @season.period_length


    collection_stat_list = []
    @basic_stats = []
    collection_team_stats = TeamStat.where(season_id: @season_id).joins(:stat_list).where('stat_lists.collectable' => true);
    basic_team_stats = TeamStat.where(season_id: @season_id).joins(:stat_list).where('stat_lists.advanced' => false, 'stat_lists.team_stat' =>false, 'stat_lists.is_percent' => false);
    collection_team_stats.each do |stat|
      collection_stat_list.push(StatList.find_by_id(stat.stat_list_id))
    end

    @collection_stats = Stats::CollectableStatsService.new({
      stats: collection_stat_list
    }).call

    gon.collection_stats = @collection_stats

    basic_team_stats.each do |stat|
      @basic_stats.push(StatList.find_by_id(stat.stat_list_id))
    end
    gon.basic_stats = @basic_stats

    ## return an array which has the fields that we will want to display in the stat table, and their corresponding ordering number.
    @stat_table_columns = Stats::StatTableColumnsService.new({
      stats: @basic_stats,
      is_advanced: false
    }).call
    gon.stat_table_columns = @stat_table_columns.reverse!
  end

  def plays
    @small_header = true
    gon.primary_color = 9;
    gon.secondary_color = 13;
  end

end
