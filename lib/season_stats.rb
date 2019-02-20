module SeasonStats

  def most_hits(season) #SeasonStats
    gt_hash = @game_teams.group_by do |game_team|
      game_team.season
    end
    team_agg = Hash.new { |hash, key| hash[key] = [] }
    team_hits_array_hash = gt_hash[season].inject(team_agg) do |hash, game_team|
      hash[game_team.team_id] << game_team.hits
      hash
    end
    team_hits_array_hash.each do |team_id, hits_array|
      team_hits_array_hash[team_id] = hits_array.sum
    end
    most_hits = team_hits_array_hash.max_by { |team_id, hits_tally| hits_tally }[0]
    convert_team_id_and_team_name(most_hits)
  end

  def least_hits(season) #SeasonStats
    gt_hash = @game_teams.group_by do |game_team|
      game_team.season
    end
    team_agg = Hash.new { |hash, key| hash[key] = [] }
    team_hits_array_hash = gt_hash[season].inject(team_agg) do |hash, game_team|
      hash[game_team.team_id] << game_team.hits
      hash
    end
    team_hits_array_hash.each do |team_id, hits_array|
      team_hits_array_hash[team_id] = hits_array.sum
    end
    least_hits = team_hits_array_hash.min_by { |team_id, hits_tally| hits_tally }[0]
    convert_team_id_and_team_name(least_hits)
  end



end
