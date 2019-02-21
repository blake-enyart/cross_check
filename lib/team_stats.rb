module TeamStats

  def best_season(team_id)
    game_teams_by_season = @game_teams.group_by(&:season)
    game_teams_by_season.each do |season, game_team_array|
      game_team_array.sort_by(&:game_id)
      game_grouping = []
      game_team_array.each_with_index do |game_team, index|
        if game_team_array[index+1] != nil
          if game_team.game_id == game_team_array[index+1].game_id
            game_grouping << [game_team, game_team_array[index+1]]
          end
        end
      end
      game_teams_by_season[season] = game_grouping
    end
    game_teams_by_season.each do |season, game_pair_array|
      game_pair_array.select! do |game_pair|
        game_pair[0].team_id == team_id ||
        game_pair[1].team_id == team_id
      end
    end
    wins_for_team = Hash.new { |hash, key| hash[key] = 0 }
    game_teams_by_season.keys.each do |season|
      wins_for_team[season]
    end
    game_teams_by_season.each do |season, game_pair_array|
      wins_for_team[season] = wins_for_team(game_pair_array, team_id)
    end
    wins_for_team.max_by { |season, wins| wins }[0]
  end

  def worst_season(team_id)
    game_teams_by_season = @game_teams.group_by(&:season)
    game_teams_by_season.each do |season, game_team_array|
      game_team_array.sort_by(&:game_id)
      game_grouping = []
      game_team_array.each_with_index do |game_team, index|
        if game_team_array[index+1] != nil
          if game_team.game_id == game_team_array[index+1].game_id
            game_grouping << [game_team, game_team_array[index+1]]
          end
        end
      end
      game_teams_by_season[season] = game_grouping
    end
    game_teams_by_season.each do |season, game_pair_array|
      game_pair_array.select! do |game_pair|
        game_pair[0].team_id == team_id ||
        game_pair[1].team_id == team_id
      end
    end
    wins_for_team = Hash.new { |hash, key| hash[key] = 0 }
    game_teams_by_season.keys.each do |season|
      wins_for_team[season]
    end
    game_teams_by_season.each do |season, game_pair_array|
      wins_for_team[season] = wins_for_team(game_pair_array, team_id)
    end
    wins_for_team.min_by { |season, wins| wins }[0]
  end

  def wins_for_team(game_pair_array, team_id)
    wins_for_team = 0
    game_pair_array.each do |game_pair|
      outcome = win_determination(game_pair)
      if outcome[0] == team_id
        wins_for_team += 1
      end
    end
    wins_for_team
  end

  def most_goals_scored(team_id)
    most_goals = group_by_team_id(@game_teams)[team_id].max_by do |game_team|
      game_team.goals
    end
    most_goals.goals
  end

  def fewest_goals_scored(team_id)
    fewest_goals = group_by_team_id(@game_teams)[team_id].min_by do |game_team|
      game_team.goals
    end
    fewest_goals.goals
  end

  def team_info(team_id)
    hash = {}
    @teams.each do |team|
      if team.team_id == team_id
        team.instance_variables.each do |variable|
          hash[variable.to_s[1..-1]] = team.instance_variable_get(variable)
        end
      end
    end
    hash
  end

  def worst_loss(team_id)
    away_tracker = []
    home_tracker = []
    @games.each do |game|
      if game.away_team_id == team_id
        away_tracker << game
      elsif game.home_team_id == team_id
        home_tracker << game
      end
    end
    diff = []
    away_tracker.each do |game|
      diff << (game.away_goals - game.home_goals)
    end
    home_tracker.each do |game|
      diff << (game.home_goals - game.away_goals)
    end
    diff.max
  end

  def biggest_team_blowout(team_id)
    away_tracker = []
    home_tracker = []
    @games.each do |game|
      if game.away_team_id == team_id
        away_tracker << game
      elsif game.home_team_id == team_id
        home_tracker << game
      end
    end
    diff = []
    away_tracker.each do |game|
      diff << (game.away_goals - game.home_goals)
    end
    home_tracker.each do |game|
      diff << (game.home_goals - game.away_goals)
    end
    diff.min.abs
  end

  def seasonal_summary(team_id)
    game_teams_by_team_id = @game_teams.find_all do |game_team|
      game_team.team_id == team_id
    end
    game_teams_by_season_hash = game_teams_by_team_id.group_by do |game_team|
      game_team.season
    end
    pre_reg_season_hash = {}
    game_team_season_type_hash = {}
    game_teams_by_season_hash.each do |season, game_teams|
      preseason_game_teams = game_teams.find_all do |game_team|
        #example: game_id "2012030223" "2012" = season; "03" = preseason/playoff id, "0223" = game identifier(not important)
        #of "01" preseason id, "1" is [5] index; "02" = regular season id; "03" playoff/postseason id, "3"
        game_team.game_id[5] == "1"
      end
      regular_season_game_teams = game_teams.find_all do |game_team|
        game_team.game_id[5] == "2"
      end
      pre_reg_season_hash[:preseason] = preseason_game_teams
      pre_reg_season_hash[:regular_season] = regular_season_game_teams
      game_team_season_type_hash[season] = {}
      preseason_season_holder_hash = {}
      preseason_season_holder_hash[:win_percentage] = win_percentage_seasonal_summary(preseason_game_teams)
      preseason_season_holder_hash[:total_goals_scored] = total_goals_scored_ss(preseason_game_teams)
      preseason_season_holder_hash[:total_goals_against] = total_goals_against_ss(preseason_game_teams, team_id)
      preseason_season_holder_hash[:average_goals_scored] = average_goals_scored_ss(preseason_game_teams)
      preseason_season_holder_hash[:average_goals_against] = average_goals_against_ss(preseason_game_teams, team_id)
      game_team_season_type_hash[season][:preseason] = preseason_season_holder_hash
      regular_season_holder_hash = {}
      regular_season_holder_hash[:win_percentage] = win_percentage_seasonal_summary(regular_season_game_teams)
      regular_season_holder_hash[:total_goals_scored] = total_goals_scored_ss(regular_season_game_teams)
      regular_season_holder_hash[:total_goals_against] = total_goals_against_ss(regular_season_game_teams, team_id)
      regular_season_holder_hash[:average_goals_scored] = average_goals_scored_ss(regular_season_game_teams)
      regular_season_holder_hash[:average_goals_against] = average_goals_against_ss(regular_season_game_teams, team_id)
      game_team_season_type_hash[season][:regular_season] = regular_season_holder_hash
    end
    game_team_season_type_hash
  end

  def win_percentage_seasonal_summary(game_team_array)
    total_games = game_team_array.length
    total_wins = game_team_array.count do |game_team|
      game_team.won == "TRUE"
    end
    if total_games == 0
      return 0.to_f
    else
      (total_wins.to_f / total_games.to_f).round(2)
    end
  end

  def total_goals_scored_ss(game_team_array)
    game_team_array.sum do |game_team|
      game_team.goals
    end
  end

  def average_goals_scored_ss(game_team_array)
    if game_team_array.length == 0
      return 0.to_f
    else
      (total_goals_scored_ss(game_team_array).to_f / game_team_array.length.to_f).round(2)
    end
  end

  def total_goals_against_ss(game_team_array, team_id)
    total_goals_against = 0
    game_team_array.each do |game_team|
      @games.each do |game|
        if game.game_id == game_team.game_id
          if team_id == game.away_team_id
            total_goals_against += game.home_goals
          else
            total_goals_against += game.away_goals
          end
        end
      end
    end
    total_goals_against
  end

  def average_goals_against_ss(game_team_array, team_id)
    if game_team_array.length == 0
      return 0.to_f
    else
      (total_goals_against_ss(game_team_array, team_id).to_f / game_team_array.length.to_f).round(2)
    end
  end

  def average_win_percentage(team_id)
    sort = sort_game_team_pairs_by_attribute_and_select(:team_id, team_id)
    total_games = sort[team_id].size
    total_wins = wins_for_team(sort[team_id], team_id)
    (total_wins.to_f/total_games).round(2)
  end

  def sort_game_team_pairs_by_attribute_and_select(attr_sym, selection)
    sort_game_teams = @game_teams.sort_by(&:game_id)
    game_grouping = []
    sort_game_teams.each_with_index do |game_team, index|
      if sort_game_teams[index+1] != nil
        if game_team.game_id == sort_game_teams[index+1].game_id
          game_grouping << [game_team, sort_game_teams[index+1]]
        end
      end
    end
    selection_hash = Hash.new { |hash, key| hash[key] = [] }
    game_grouping.each do |game_pair|
      if game_pair[0].send(attr_sym) == selection || game_pair[1].send(attr_sym) == selection
        selection_hash[selection] << game_pair
      end
    end
    selection_hash
  end

  def favorite_opponent(team_id)
    selected_game_pairs = sort_game_team_pairs_by_attribute_and_select(:team_id, team_id)[team_id]
    game_pairs_hash = Hash.new { |hash, key| hash[key] = [] }
    selected_game_pairs.each do |game_pair|
      if game_pair[0].team_id != team_id
        game_pairs_hash[game_pair[0].team_id] << game_pair
      elsif game_pair[1].team_id != team_id
        game_pairs_hash[game_pair[1].team_id] << game_pair
      end
    end
    game_pairs_hash.each do |team_id_opponent, game_pair_array|
      total_games = game_pair_array.size
      total_wins = wins_for_team(game_pair_array, team_id)
      average_win = (total_wins.to_f/total_games)*100
      average_win = average_win.round(2)
      game_pairs_hash[team_id_opponent] = average_win
    end
    favorite_opponent = game_pairs_hash.max_by { |team_id_opponent, win_percentage| win_percentage }[0]
    convert_team_id_and_team_name(favorite_opponent)
  end

  def rival(team_id)
    selected_game_pairs = sort_game_team_pairs_by_attribute_and_select(:team_id, team_id)[team_id]
    game_pairs_hash = Hash.new { |hash, key| hash[key] = [] }
    selected_game_pairs.each do |game_pair|
      if game_pair[0].team_id != team_id
        game_pairs_hash[game_pair[0].team_id] << game_pair
      elsif game_pair[1].team_id != team_id
        game_pairs_hash[game_pair[1].team_id] << game_pair
      end
    end
    game_pairs_hash.each do |team_id_opponent, game_pair_array|
      total_games = game_pair_array.size
      total_wins = wins_for_team(game_pair_array, team_id_opponent)
      average_win = (total_wins.to_f/total_games)*100
      average_win = average_win.round(2)
      game_pairs_hash[team_id_opponent] = average_win
    end
    favorite_opponent = game_pairs_hash.max_by { |team_id_opponent, win_percentage| win_percentage }[0]
    convert_team_id_and_team_name(favorite_opponent)
  end

  def head_to_head(team_id)
    games_played_by_team = @game_teams.find_all do |game_team|
      game_team.team_id == team_id
    end
    opposing_team_id_info = []
    games_played_by_team.each do |team_id_game_team|
      game_team_pairs = @game_teams.find_all do |game_team|
        game_team.game_id == team_id_game_team.game_id
      end
      game_team_pairs.each do |one_game_team|
        if one_game_team.team_id != team_id
          opposing_team_id_info << [one_game_team.team_id, one_game_team.won]
        end
      end
    end
    opposing_team_by_won = opposing_team_id_info.group_by do |opposing_team_info|
      opposing_team_info[0]
    end
    total_wins = 0
    total_wins_and_games_hash = {}
    opposing_team_by_won.each do |team_id_opponent, opposing_team_info|
      total_games = opposing_team_info.length
      total_wins = opposing_team_info.count do |info|
        info[1] == "FALSE"
      end
      total_wins_and_games_hash[team_id_opponent] = (total_wins.to_f / total_games.to_f).round(2)
    end
    final_hash = {}
    total_wins_and_games_hash.each do |team_id_opponent, win_percentage|
      final_hash[convert_team_id_and_team_name(team_id_opponent)] = win_percentage
    end
    final_hash
  end
end
