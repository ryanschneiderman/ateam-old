class Seeds::SeedDemoTeamService
	def initialize(params)
		# @team_id = params[:team_id]
		# @season_id = params[:season_id]
	end

	def call

		user = User.create(
			first_name: "admin",
			last_name: "",
			front_page: true,
			email: "rschneides21@yahoo.com",
			password: "silva21",
			password_confirmation: "silva21"
		)

		team = Team.create(
			sport_id: 1,
			user_id: user.id,
			paid: true
		)
		season = Season.create(
			team_id: team.id,
			year1: 2019,
			year2: 2020,
			primary_color: 6,
			secondary_color: 13,
			num_periods: 4,
			period_length: 12,
			team_name: "Celtics",
			multiple_years_flag: true,
		)

		puts "*********************SEASON ID*********************"
		puts season.id
		puts "*********************TEAM ID*********************"
		puts team.id

		TeamStat.create(stat_list_id: 1, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 2, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 3, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 4, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 5, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 6, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 7, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 8, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 9, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 10, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 11, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 12, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 13, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 14, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 15, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 16, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 17, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 18, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 19, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 20, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 21, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 22, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 23, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 24, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 25, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 26, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 27, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 28, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 29, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 30, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 31, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 32, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 33, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 34, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 35, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 36, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 37, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 38, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 39, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 40, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 41, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 42, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 45, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 46, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 47, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 48, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 49, team_id: team.id, show: true, season_id: season.id)
		TeamStat.create(stat_list_id: 50, team_id: team.id, show: true, season_id: season.id)

		jayson = Member.create(team_id: team.id, season_id: season.id, alt_id: 202689, season_minutes: 0, games_played: 0, is_player: true, nickname: "Jayson", number: 0)
		puts "******************************************JAYSON ID ******************************************"
		puts jayson.id
		jaylen = Member.create(team_id: team.id, season_id: season.id, alt_id: 1628369, season_minutes: 0, games_played: 0, is_player: true, nickname: "Jaylen", number: 7)
		puts "******************************************JAYLEN ID ******************************************"
		puts jaylen.id
		marcus = Member.create(team_id: team.id, season_id: season.id, alt_id: 1627759, season_minutes: 0, games_played: 0, is_player: true, nickname: "Marcus", number: 36)
		puts "******************************************Marcus ID ******************************************"
		puts marcus.id
		kemba = Member.create(team_id: team.id, season_id: season.id, alt_id: 203935, season_minutes: 0, games_played: 0, is_player: true, nickname: "Kemba", number: 8)
		puts "******************************************KEMBA ID ******************************************"
		puts kemba.id
		gordon = Member.create(team_id: team.id, season_id: season.id, alt_id: 202330, season_minutes: 0, games_played: 0, is_player: true, nickname: "Gordon", number: 20)
		puts "******************************************GORDON ID ******************************************"
		puts gordon.id
		daniel = Member.create(team_id: team.id, season_id: season.id, alt_id: 1628464, season_minutes: 0, games_played: 0, is_player: true, nickname: "Daniel", number: 27)
		puts "******************************************DANIEL ID ******************************************"
		puts daniel.id
		brad = Member.create(team_id: team.id, season_id: season.id, alt_id: 202954, season_minutes: 0, games_played: 0, is_player: true, nickname: "Brad", number: 9)
		puts "******************************************BRAD ID ******************************************"
		puts brad.id
		grant = Member.create(team_id: team.id, season_id: season.id, alt_id: 1629684, season_minutes: 0, games_played: 0, is_player: true, nickname: "Grant", number: 12)
		puts "******************************************GRANT ID ******************************************"
		puts grant.id
		semi = Member.create(team_id: team.id, season_id: season.id, alt_id: 1628400, season_minutes: 0, games_played: 0, is_player: true, nickname: "Semi", number: 37)
		puts "******************************************SEMI ID ******************************************"
		puts semi.id
		enes = Member.create(team_id: team.id, season_id: season.id, alt_id: 202683, season_minutes: 0, games_played: 0, is_player: true, nickname: "Enes", number: 11)
		puts "******************************************ENES ID ******************************************"
		puts enes.id
		javonte = Member.create(team_id: team.id, season_id: season.id, alt_id: 1629750, season_minutes: 0, games_played: 0, is_player: true, nickname: "Javonte", number: 43)
		puts "******************************************JAVONTE ID ******************************************"
		puts javonte.id
		robert = Member.create(team_id: team.id, season_id: season.id, alt_id: 1629057, season_minutes: 0, games_played: 0, is_player: true, nickname: "Robert", number: 44)
		puts "******************************************ROBERT ID ******************************************"
		puts robert.id
		romeo = Member.create(team_id: team.id, season_id: season.id, alt_id: 1629641, season_minutes: 0, games_played: 0, is_player: true, nickname: "Romeo", number: 45)
		puts "******************************************ROMEO ID ******************************************"
		puts romeo.id
		carsen = Member.create(team_id: team.id, season_id: season.id, alt_id: 1629035, season_minutes: 0, games_played: 0, is_player: true, nickname: "Carsen", number: 4)
		puts "******************************************CARSEN ID ******************************************"
		puts carsen.id


		team_season_makes = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: false, stat_list_id: 1,  value: 2936)
		team_season_misses = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: false, stat_list_id: 2,  value: 3424)
		team_season_assists = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: false, stat_list_id: 3,  value: 1633)
		team_season_oreb = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: false, stat_list_id: 4,  value: 755)
		team_season_dreb = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: false, stat_list_id: 5,  value: 2511)
		team_season_stls = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: false, stat_list_id: 6,  value: 587)
		team_season_tov = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: false, stat_list_id: 7,  value: 976)
		team_season_blk = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: false, stat_list_id: 8,  value: 399)
		team_season_threes = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: false, stat_list_id: 11,  value: 897)
		team_season_three_misses = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: false, stat_list_id: 12,  value: 1555)
		team_season_ft_makes = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: false, stat_list_id: 13,  value: 1324)
		team_season_ft_misses = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: false, stat_list_id: 14,  value: 330)
		team_season_points = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: false, stat_list_id: 15,  value: 8093)
		team_season_minutes = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: false, stat_list_id: 16,  value: 1031400)

		opp_season_makes = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: true, stat_list_id: 1,  value: 2730)
		opp_season_misses = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: true, stat_list_id: 2,  value: 3450)
		opp_season_assists = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: true, stat_list_id: 3,  value: 1591)
		opp_season_oreb = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: true, stat_list_id: 4,  value: 725)
		opp_season_dreb = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: true, stat_list_id: 5,  value: 2411)
		opp_season_stls = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: true, stat_list_id: 6,  value: 503)
		opp_season_tov = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: true, stat_list_id: 7,  value: 1079)
		opp_season_blk = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: true, stat_list_id: 8,  value: 390)
		opp_season_threes = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: true, stat_list_id: 11,  value: 841)
		opp_season_three_misses = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: true, stat_list_id: 12,  value: 1637)
		opp_season_ft_makes = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: true, stat_list_id: 13,  value: 1332)
		opp_season_ft_misses = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: true, stat_list_id: 14,  value: 405)
		opp_season_points = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: true, stat_list_id: 15,  value:7633)
		opp_season_minutes = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: true, stat_list_id: 16,  value: 1031400)

		team_season_fouls = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: false, stat_list_id: 17,  value: 1553)
		opp_season_fouls = TeamSeasonStat.create(team_id: team.id, season_id: season.id, is_opponent: true, stat_list_id: 17,  value: 1487)

		

			
	end
end