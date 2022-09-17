
class PagesController < ApplicationController
	skip_before_action :authenticate_user!, only: [:index, :about, :tutorial, :reset, :nba_api,  :seeding_endpoint,]
  skip_before_action :verify_authenticity_token, only: [:seeding_endpoint]
	def index
		if user_signed_in?
			@members = Member.joins(:season).select("seasons.team_id as team_id, members.*").where("members.user_id" => current_user.id).sort_by{|e| e.season_id}.reverse

			if @members.length > 0
				redirect_to team_season_path(@members.first.team_id, @members.first.season_id)
			end
		end	
  end

  def reset
    # TruncateTeamsService.new().call
    # TruncateUsersService.new().call
    redirect_to root_path
  end

  def no_access
  end

  def react_test
  end

  def seeding_endpoint
    Seeds::Receivers::ReceiveSeedDataService.new({data: params[:data], data_kind: params[:data_kind]}).call
  end

  def nba_api
    #StatGranule.where(season_id: 1).destroy_all

    # Seeds::Senders::SendShotDataService.new({member_id: 1, player_id: 202689, season_id: 1}).call
    # Seeds::Senders::SendShotDataService.new({member_id: 2, player_id: 1628369, season_id: 1}).call
    # Seeds::Senders::SendShotDataService.new({member_id: 3, player_id: 1627759, season_id: 1}).call
    # Seeds::Senders::SendShotDataService.new({member_id: 4, player_id: 203935, season_id: 1}).call
    # Seeds::Senders::SendShotDataService.new({member_id: 5, player_id: 202330, season_id: 1}).call
    # Seeds::Senders::SendShotDataService.new({member_id: 6, player_id: 1628464, season_id: 1}).call
    # Seeds::Senders::SendShotDataService.new({member_id: 7, player_id: 202954, season_id: 1}).call
    # Seeds::Senders::SendShotDataService.new({member_id: 8, player_id: 1629684, season_id: 1}).call
    # Seeds::Senders::SendShotDataService.new({member_id: 9, player_id: 1628400, season_id: 1}).call
    # Seeds::Senders::SendShotDataService.new({member_id: 10, player_id: 202683, season_id: 1}).call
    # Seeds::Senders::SendShotDataService.new({member_id: 11, player_id: 1629750, season_id: 1}).call
    # Seeds::Senders::SendShotDataService.new({member_id: 12, player_id: 1629057, season_id: 1}).call
    # Seeds::Senders::SendShotDataService.new({member_id: 13, player_id: 1629641, season_id: 1}).call
    # Seeds::Senders::SendShotDataService.new({member_id: 14, player_id: 1629035, season_id: 1}).call


    # Seeds::Senders::SendPlayerShotDataService.new({member_id: 1, player_id: 202689, season_id: 1}).call
    # Seeds::Senders::SendPlayerShotDataService.new({member_id: 2, player_id: 1628369, season_id: 1}).call
    # Seeds::Senders::SendPlayerShotDataService.new({member_id: 3, player_id: 1627759, season_id: 1}).call
    # Seeds::Senders::SendPlayerShotDataService.new({member_id: 4, player_id: 203935, season_id: 1}).call
    # Seeds::Senders::SendPlayerShotDataService.new({member_id: 5, player_id: 202330, season_id: 1}).call

    # Seeds::Senders::SendPlayerShotDataService.new({member_id: 46, player_id: 1628464, season_id: 1}).call
    # Seeds::Senders::SendPlayerShotDataService.new({member_id: 47, player_id: 202954, season_id: 1}).call
    # Seeds::Senders::SendPlayerShotDataService.new({member_id: 48, player_id: 1629684, season_id: 1}).call
    # Seeds::Senders::SendPlayerShotDataService.new({member_id: 49, player_id: 1628400, season_id: 1}).call
    # Seeds::Senders::SendPlayerShotDataService.new({member_id: 50, player_id: 202683, season_id: 1}).call
    # Seeds::Senders::SendPlayerShotDataService.new({member_id: 51, player_id: 1629750, season_id: 1}).call
    # Seeds::Senders::SendPlayerShotDataService.new({member_id: 52, player_id: 1629057, season_id: 1}).call
    # Seeds::Senders::SendPlayerShotDataService.new({member_id: 53, player_id: 1629641, season_id: 1}).call
    # Seeds::Senders::SendPlayerShotDataService.new({member_id: 54, player_id: 1629035, season_id: 1}).call

    #RestClient.post 'https://ateamsports.app/test_endpoint', {test: 'WE HAVE LIFTOFF'}.to_json, {content_type: :json, accept: :json}
    #Seeds::Senders::SendDemoTeamService.new({}).call
    # Seeds::AdvancedStatGameService.new({team_id: 1, season_id: 1}).call
    # Stats::GameModeCallbackService.new({
    #   team_id: 1,
    #   curr_season_id: 1
    # }).call

  

    # Stats::Lineups::LineupStatRankingService.new({
    #   team_id: 1,
    #   season_id: 1
    # }).call
    # StatList.find_by_id(43).update(hidden: true)
    # StatList.find_by_id(44).update(hidden: true)
    # TeamStat.where(stat_list_id: 43).destroy_all
    # TeamStat.where(stat_list_id: 44).destroy_all
  end





  def about
    @small_header = true
  end

  def tutorial
    @small_header = true
  end

  def admin
    @small_header = true
    if current_user.admin

        if cookies[:season_id].present?
            @season = Season.find_by_id(cookies[:season_id])
        end
        @seasons = Season.joins(team: :user).select("seasons.*, seasons.id as season_id, users.*, teams.*").all
        # @seasons.each do |season|
        #   ft_rate = TeamStat.where(season_id: season.season_id, stat_list_id: 46)
        #   if ft_rate.length == 0
        #     TeamStat.create(stat_list_id: 46, season_id: season.season_id)
        #   end
        # end
        @teams = Team.joins(:user).select("teams.*, teams.id as team_id, users.*").all
        @users = User.all
    else
        redirect_to root_path
    end
  end

  def get_team_stats
    if current_user.admin
      puts "season_id"
      puts params[:season_id]
      team_stats = TeamStat.joins(:stat_list).select("stat_lists.stat as stat, team_stats.stat_list_id as stat_list_id").where("team_stats.season_id" => params[:season_id], "stat_lists.team_stat" => true, "stat_lists.advanced" => true).sort_by{|e| e.stat_list_id}
      render :json => {team_stats: team_stats}
    end
  end

end
