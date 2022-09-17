class Seeds::Receivers::SeedSeasonStatService
	def initialize(params)
		@member_id = params[:data][:member_id]
		@season_id = params[:data][:season_id]
		@json = params[:data][:json]
	end

	def call
		json = @json
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
			season_id: @season_id
		})

		stat_hash.push({
			value: stat_obj["FGA"] - stat_obj["FGM"],
			stat_list_id: 2,
			member_id: @member_id,
			season_id: @season_id
		})


		stat_hash.push({
			value: stat_obj["AST"],
			stat_list_id: 3,
			member_id: @member_id,
			season_id: @season_id
		})


		stat_hash.push({
			value: stat_obj["OREB"],
			stat_list_id: 4,
			member_id: @member_id,
			season_id: @season_id
		})


		stat_hash.push({
			value: stat_obj["DREB"],
			stat_list_id: 5,
			member_id: @member_id,
			season_id: @season_id
		})


		stat_hash.push({
			value: stat_obj["STL"],
			stat_list_id: 6,
			member_id: @member_id,
			season_id: @season_id
		})


		stat_hash.push({
			value: stat_obj["TOV"],
			stat_list_id: 7,
			member_id: @member_id,
			season_id: @season_id
		})

		stat_hash.push({
			value: stat_obj["BLK"],
			stat_list_id: 8,
			member_id: @member_id,
			season_id: @season_id
		})

		stat_hash.push({
			value: stat_obj["FG3M"],
			stat_list_id: 11,
			member_id: @member_id,
			season_id: @season_id
		})

		stat_hash.push({
			value: stat_obj["FG3A"] - stat_obj["FG3M"],
			stat_list_id: 12,
			member_id: @member_id,
			season_id: @season_id
		})

		stat_hash.push({
			value: stat_obj["FTM"],
			stat_list_id: 13,
			member_id: @member_id,
			season_id: @season_id
		})

		stat_hash.push({
			value: stat_obj["FTA"] - stat_obj["FTM"],
			stat_list_id: 14,
			member_id: @member_id,
			season_id: @season_id
		})

		stat_hash.push({
			value: stat_obj["PTS"],
			stat_list_id: 15,
			member_id: @member_id,
			season_id: @season_id
		})

		stat_hash.push({
			value: stat_obj["MIN"] * 60,
			stat_list_id: 16,
			member_id: @member_id,
			season_id: @season_id
		})

		stat_hash.push({
			value: stat_obj["PF"],
			stat_list_id: 17,
			member_id: @member_id,
			season_id: @season_id
		})

		stat_hash.push({
			value: stat_obj["FGA"],
			stat_list_id: 47,
			member_id: @member_id,
			season_id: @season_id
		})

		stat_hash.push({
			value: stat_obj["FG3A"],
			stat_list_id: 48,
			member_id: @member_id,
			season_id: @season_id
		})

		stat_hash.push({
			value: stat_obj["FTA"],
			stat_list_id: 49,
			member_id: @member_id,
			season_id: @season_id
		})

		stat_hash.push({
			value: stat_obj["FG_PCT"],
			stat_list_id: 26,
			member_id: @member_id,
			season_id: @season_id
		})

		stat_hash.push({
			value: stat_obj["FG3_PCT"],
			stat_list_id: 27,
			member_id: @member_id,
			season_id: @season_id
		})

		stat_hash.push({
			value: stat_obj["FT_PCT"],
			stat_list_id: 28,
			member_id: @member_id,
			season_id: @season_id
		})
	end




end





