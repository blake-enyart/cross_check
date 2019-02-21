module SeasonStats

  def most_hits(season)
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

  def least_hits(season)
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

  def biggest_bust(season)
    selected_game_pairs = @game_team_pairs.select do |game_pair|
      game_pair[0].season == season
    end
    regular_games = []
    preseason_games = []
    selected_game_pairs.each do |game_pair|
      if game_pair[0].game_id[4..5] == '02'
        regular_games << game_pair
      elsif game_pair[0].game_id[4..5] == '03'
        preseason_games << game_pair
      end
    end
    gp_by_team_id_regular = Hash.new { |hash, key| hash[key] = [] }
    regular_games.each do |game_pair|
      gp_by_team_id_regular[game_pair[0].team_id] << game_pair
      gp_by_team_id_regular[game_pair[1].team_id] << game_pair
    end
    gp_by_team_id_regular.each do |team_id, game_pair_array|
      total_games = game_pair_array.size
      total_wins = wins_for_team(game_pair_array, team_id)
      average_win = (total_wins.to_f/total_games)*100
      average_win = average_win.round(2)
      gp_by_team_id_regular[team_id] = average_win
    end
    gp_by_team_id_preseason = Hash.new { |hash, key| hash[key] = [] }
    preseason_games.each do |game_pair|
      gp_by_team_id_preseason[game_pair[0].team_id] << game_pair
      gp_by_team_id_preseason[game_pair[1].team_id] << game_pair
    end
    gp_by_team_id_preseason.each do |team_id, game_pair_array|
      total_games = game_pair_array.size
      total_wins = wins_for_team(game_pair_array, team_id)
      average_win = (total_wins.to_f/total_games)*100
      average_win = average_win.round(2)
      gp_by_team_id_preseason[team_id] = average_win
    end
    biggest_bust = {}
    gp_by_team_id_preseason.each do |team_id, win_percent|
      pre_reg_decrease = win_percent - gp_by_team_id_regular[team_id]
      biggest_bust[team_id] = pre_reg_decrease
    end
    biggest_bust = biggest_bust.max_by { |team_id, win_percent| win_percent }[0]
    convert_team_id_and_team_name(biggest_bust)
  end

  def biggest_surprise(season)
    selected_game_pairs = @game_team_pairs.select do |game_pair|
      game_pair[0].season == season
    end
    regular_games = []
    preseason_games = []
    selected_game_pairs.each do |game_pair|
      if game_pair[0].game_id[4..5] == '02'
        regular_games << game_pair
      elsif game_pair[0].game_id[4..5] == '03'
        preseason_games << game_pair
      end
    end
    gp_by_team_id_regular = Hash.new { |hash, key| hash[key] = [] }
    regular_games.each do |game_pair|
      gp_by_team_id_regular[game_pair[0].team_id] << game_pair
      gp_by_team_id_regular[game_pair[1].team_id] << game_pair
    end
    gp_by_team_id_regular.each do |team_id, game_pair_array|
      total_games = game_pair_array.size
      total_wins = wins_for_team(game_pair_array, team_id)
      average_win = (total_wins.to_f/total_games)*100
      average_win = average_win.round(2)
      gp_by_team_id_regular[team_id] = average_win
    end
    gp_by_team_id_preseason = Hash.new { |hash, key| hash[key] = [] }
    preseason_games.each do |game_pair|
      gp_by_team_id_preseason[game_pair[0].team_id] << game_pair
      gp_by_team_id_preseason[game_pair[1].team_id] << game_pair
    end
    gp_by_team_id_preseason.each do |team_id, game_pair_array|
      total_games = game_pair_array.size
      total_wins = wins_for_team(game_pair_array, team_id)
      average_win = (total_wins.to_f/total_games)*100
      average_win = average_win.round(2)
      gp_by_team_id_preseason[team_id] = average_win
    end
    biggest_surprise = {}
    gp_by_team_id_preseason.each do |team_id, win_percent|
      pre_reg_decrease = win_percent - gp_by_team_id_regular[team_id]
      biggest_surprise[team_id] = pre_reg_decrease
    end
    biggest_surprise = biggest_surprise.min_by { |team_id, win_percent| win_percent }[0]
    convert_team_id_and_team_name(biggest_surprise)
  end

end
