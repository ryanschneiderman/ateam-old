class Seeds::Receivers::SeedLineupStatService
	def initialize(params)
		@member_id = params[:data][:member_id]
		@season_id = params[:data][:season_id]
		@team_id = params[:data][:team_id]
		@is_opponent = false
		@json = params[:data][:json]
	end

	def call
		json = @json

		
		stat_hash = []
		lineup_info = json["resultSets"][1]["rowSet"]
		lineup_stats = []
		stat_hash = []

		lineup_info.each do |lineup|
			i = 0
			stat_obj = {}
			lineup.each do |data_point|
				stat_obj.merge!({json["resultSets"][1]["headers"][i] => data_point})
				i+=1
			end
			lineup_stats.push(stat_obj)
			
			if lineup_members_exists(stat_obj)
				ids = get_linup_member_ids(stat_obj)
				lineup = FindLineupService.new(ids: ids, season_id: @season_id).call()
				if(lineup == nil)
					lineup = Lineup.create(team_id: @team_id, season_id: @season_id, season_minutes: stat_obj["MIN"]*60)
					create_lineup_members(stat_obj, lineup.id)
				end
				stat_hash = create_stats(stat_obj, lineup, stat_hash)
			end
		end
		LineupStat.import stat_hash
	end


	private 

	def lineup_members_exists(stat_obj)
		ids = stat_obj["GROUP_ID"].split("-")
		if Member.where(season_id: @season_id, alt_id: ids[1]).take.nil? || Member.where(season_id: @season_id, alt_id: ids[2]).take.nil? || Member.where(season_id: @season_id, alt_id: ids[3]).take.nil? || Member.where(season_id: @season_id, alt_id: ids[4]).take.nil? || Member.where(season_id: @season_id, alt_id: ids[5]).take.nil?
			return false
		else
			return true
		end
	end

	def get_linup_member_ids(stat_obj)
		ids = stat_obj["GROUP_ID"].split("-")
		member_1 = Member.where(alt_id: ids[1], season_id: @season_id).take
		member_2 = Member.where(alt_id: ids[2], season_id: @season_id).take
		member_3 = Member.where(alt_id: ids[3], season_id: @season_id).take
		member_4 = Member.where(alt_id: ids[4], season_id: @season_id).take
		member_5 = Member.where(alt_id: ids[5], season_id: @season_id).take

		return [member_1.id, member_2.id, member_3.id, member_4.id, member_5.id]
	end

	def create_lineup_members(stat_obj,lineup_id)
		ids = stat_obj["GROUP_ID"].split("-")
		member_1 = Member.where(alt_id: ids[1], season_id: @season_id).take
		LineupsMember.create(member_id: member_1.id, lineup_id: lineup_id)
		member_2 = Member.where(alt_id: ids[2], season_id: @season_id).take
		LineupsMember.create(member_id: member_2.id, lineup_id: lineup_id)
		member_3 = Member.where(alt_id: ids[3], season_id: @season_id).take
		LineupsMember.create(member_id: member_3.id, lineup_id: lineup_id)
		member_4 = Member.where(alt_id: ids[4], season_id: @season_id).take
		LineupsMember.create(member_id: member_4.id, lineup_id: lineup_id)
		member_5 = Member.where(alt_id: ids[5], season_id: @season_id).take
		LineupsMember.create(member_id: member_5.id, lineup_id: lineup_id)
	end

	def create_stats (stat_obj, lineup, stat_hash)
		
		stat_hash.push({
			value: stat_obj["FGM"],
			stat_list_id: 1,
			lineup_id: lineup.id,
			season_id: @season_id,
			is_opponent: @is_opponent
		})

		stat_hash.push({
			value: stat_obj["FGA"] - stat_obj["FGM"],
			stat_list_id: 2,
			lineup_id: lineup.id,
			season_id: @season_id,
			is_opponent: @is_opponent
		})


		stat_hash.push({
			value: stat_obj["AST"],
			stat_list_id: 3,
			lineup_id: lineup.id,
			season_id: @season_id,
			is_opponent: @is_opponent
		})


		stat_hash.push({
			value: stat_obj["OREB"],
			stat_list_id: 4,
			lineup_id: lineup.id,
			season_id: @season_id,
			is_opponent: @is_opponent
		})


		stat_hash.push({
			value: stat_obj["DREB"],
			stat_list_id: 5,
			lineup_id: lineup.id,
			season_id: @season_id,
			is_opponent: @is_opponent
		})


		stat_hash.push({
			value: stat_obj["STL"],
			stat_list_id: 6,
			lineup_id: lineup.id,
			season_id: @season_id,
			is_opponent: @is_opponent
		})


		stat_hash.push({
			value: stat_obj["TOV"],
			stat_list_id: 7,
			lineup_id: lineup.id,
			season_id: @season_id,
			is_opponent: @is_opponent
		})

		stat_hash.push({
			value: stat_obj["BLK"],
			stat_list_id: 8,
			lineup_id: lineup.id,
			season_id: @season_id,
			is_opponent: @is_opponent
		})

		stat_hash.push({
			value: stat_obj["FG3M"],
			stat_list_id: 11,
			lineup_id: lineup.id,
			season_id: @season_id,
			is_opponent: @is_opponent
		})

		stat_hash.push({
			value: stat_obj["FG3A"] - stat_obj["FG3M"],
			stat_list_id: 12,
			lineup_id: lineup.id,
			season_id: @season_id,
			is_opponent: @is_opponent
		})

		stat_hash.push({
			value: stat_obj["FTM"],
			stat_list_id: 13,
			lineup_id: lineup.id,
			season_id: @season_id,
			is_opponent: @is_opponent
		})

		stat_hash.push({
			value: stat_obj["FTA"] - stat_obj["FTM"],
			stat_list_id: 14,
			lineup_id: lineup.id,
			season_id: @season_id,
			is_opponent: @is_opponent
		})

		stat_hash.push({
			value: stat_obj["PTS"],
			stat_list_id: 15,
			lineup_id: lineup.id,
			season_id: @season_id,
			is_opponent: @is_opponent
		})

		stat_hash.push({
			value: stat_obj["MIN"] * 60,
			stat_list_id: 16,
			lineup_id: lineup.id,
			season_id: @season_id,
			is_opponent: @is_opponent
		})

		stat_hash.push({
			value: stat_obj["PF"],
			stat_list_id: 17,
			lineup_id: lineup.id,
			season_id: @season_id,
			is_opponent: @is_opponent
		})

		stat_hash.push({
			value: stat_obj["FGA"],
			stat_list_id: 47,
			lineup_id: lineup.id,
			season_id: @season_id,
			is_opponent: @is_opponent
		})

		stat_hash.push({
			value: stat_obj["FG3A"],
			stat_list_id: 48,
			lineup_id: lineup.id,
			season_id: @season_id,
			is_opponent: @is_opponent
		})

		stat_hash.push({
			value: stat_obj["FTA"],
			stat_list_id: 49,
			lineup_id: lineup.id,
			season_id: @season_id,
			is_opponent: @is_opponent
		})

		stat_hash.push({
			value: stat_obj["FG_PCT"],
			stat_list_id: 26,
			lineup_id: lineup.id,
			season_id: @season_id,
			is_opponent: @is_opponent
		})

		stat_hash.push({
			value: stat_obj["FG3_PCT"],
			stat_list_id: 27,
			lineup_id: lineup.id,
			season_id: @season_id,
			is_opponent: @is_opponent
		})

		stat_hash.push({
			value: stat_obj["FT_PCT"],
			stat_list_id: 28,
			lineup_id: lineup.id,
			season_id: @season_id,
			is_opponent: @is_opponent
		})
	end




end





