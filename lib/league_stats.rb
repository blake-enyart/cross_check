require_relative './game_stats'

module LeagueStats
  include GameStats

  def count_of_teams
    @teams.length
  end

  def best_fans
    home_away_win_difference_hash = {}
    group_game_teams_by_team_id.each do |team_id, game_teams|
      total_home_games = game_teams.count do |game_team|
        game_team.hoa == "home"
      end
      count_of_home_wins = game_teams.count do |game_team|
        game_team.hoa == "home" && game_team.won == "TRUE"
      end
      total_away_games = game_teams.count do |game_team|
        game_team.hoa == "away"
      end
      count_of_away_wins = game_teams.count do |game_team|
        game_team.hoa == "away" && game_team.won == "TRUE"
      end
      home_win_percentage_by_team = count_of_home_wins.to_f / total_home_games.to_f
      away_win_percentage_by_team = count_of_away_wins.to_f / total_away_games.to_f
      home_away_win_difference = home_win_percentage_by_team - away_win_percentage_by_team
      home_away_win_difference_hash[team_id] = home_away_win_difference
    end
    big_difference = home_away_win_difference_hash.select do |team_id, value|
      value == home_away_win_difference_hash.values.max
    end
    team_id = big_difference.keys.first
    team_object = @teams.find do |team|
      team.team_id == team_id
    end
    team_object.team_name
  end

  def worst_fans
    away_home_win_difference_hash = {}
    group_game_teams_by_team_id.each do |team_id, game_teams|
      total_home_games = game_teams.count do |game_team|
        game_team.hoa == "home"
      end
      count_of_home_wins = game_teams.count do |game_team|
        game_team.hoa == "home" && game_team.won == "TRUE"
      end
      total_away_games = game_teams.count do |game_team|
        game_team.hoa == "away"
      end
      count_of_away_wins = game_teams.count do |game_team|
        game_team.hoa == "away" && game_team.won == "TRUE"
      end
      home_win_percentage_by_team = count_of_home_wins.to_f / total_home_games.to_f
      away_win_percentage_by_team = count_of_away_wins.to_f / total_away_games.to_f
      away_home_win_difference = away_win_percentage_by_team - home_win_percentage_by_team
      away_home_win_difference_hash[team_id] = away_home_win_difference
    end
    worst_fans_array = []
    away_home_win_difference_hash.each do |team_id, away_record_value|
      if away_record_value > 0
        worst_fans_array << team_id
      end
    end
    worst_fans_team_names = []
    @teams.each do |team|
      worst_fans_array.each do |team_id|
        if team.team_id == team_id
          worst_fans_team_names << team.team_name
        end
      end
    end
    worst_fans_team_names
  end

  def best_offense
    hash = all_goals_per_team(group_by_team_id(@game_teams))
    best_team_id = hash.max_by { |team_id, team_goals| team_goals }[0]
    convert_team_id_and_team_name(best_team_id)
  end

  def worst_offense
    hash = all_goals_per_team(group_by_team_id(@game_teams))
    worst_team_id = hash.min_by { |team_id, team_goals| team_goals }[0]
    convert_team_id_and_team_name(worst_team_id)
  end

  def highest_scoring_visitor
    sorted_away_games = group_by_team_id(@games_away)
    team_id_with_average_goals = all_goals_per_team(sorted_away_games)
    best_team_id = team_id_with_average_goals.max_by { |team_id, team_goals| team_goals }[0]
    convert_team_id_and_team_name(best_team_id)
  end

  def highest_scoring_home_team
    sorted_home_games = group_by_team_id(@games_home)
    team_id_with_average_goals = all_goals_per_team(sorted_home_games)
    best_team_id = team_id_with_average_goals.max_by { |team_id, team_goals| team_goals }[0]
    convert_team_id_and_team_name(best_team_id)
  end

  def lowest_scoring_visitor
    sorted_away_games = group_by_team_id(@games_away)
    team_id_with_average_goals = all_goals_per_team(sorted_away_games)
    worst_team_id = team_id_with_average_goals.min_by { |team_id, team_goals| team_goals }[0]
    convert_team_id_and_team_name(worst_team_id)
  end

  def lowest_scoring_home_team
    sorted_home_games = group_by_team_id(@games_home)
    team_id_with_average_goals = all_goals_per_team(sorted_home_games)
    worst_team_id = team_id_with_average_goals.min_by { |team_id, team_goals| team_goals }[0]
    convert_team_id_and_team_name(worst_team_id)
  end

  def winningest_team
    win_tracker = {}
    @teams_hash.each { |team_id, team_object| win_tracker[team_id] = 0 }
    game_grouping = @game_team_pairs
    gp_by_team_id = game_pairs_by_attribute(game_grouping, :team_id)
    gp_by_team_id.each do |team_id, game_pair_array|
      total_games = game_pair_array.size
      team_wins = wins_for_team(game_pair_array, team_id)
      average = (team_wins.to_f/total_games).round(2)
      win_tracker[team_id] = average
    end
    best_team_id = win_tracker.max_by { |team_id, win_percentage| win_percentage }[0]
    convert_team_id_and_team_name(best_team_id)
  end

  def best_defense
    win_tracker = group_by_team_id(@game_teams)
    win_tracker = win_tracker.each { |k,v| win_tracker[k] = 0 }
    game_grouping = @game_teams.group_by { |row| row.game_id }
    defense_tracker = []
    game_grouping.each do |game_id, game_array|
      if game_array.length == 2
        if game_array[0].hoa == 'home'
          home_team = game_array[0]
          away_team = game_array[1]
        else
          home_team = game_array[1]
          away_team = game_array[0]
        end
        array = [home_team.team_id, away_team.goals]
        away_array = [away_team.team_id, home_team.goals]
        defense_tracker << array
        defense_tracker << away_array
      end
    end
    defense_tracker.each do |score_outcome|
      win_tracker[score_outcome [0]] += score_outcome[1]
    end
    team = win_tracker.min_by do |team_id, goals_against|
      goals_against
    end
    team = team[0]
    convert_team_id_and_team_name(team)
  end

  def worst_defense
    win_tracker = group_by_team_id(@game_teams)
    win_tracker = win_tracker.each { |k,v| win_tracker[k] = 0 }
    game_grouping = @game_teams.group_by { |row| row.game_id }
    defense_tracker = []
    game_grouping.each do |game_id, game_array|
      if game_array.length == 2
        if game_array[0].hoa == 'home'
          home_team = game_array[0]
          away_team = game_array[1]
        else
          home_team = game_array[1]
          away_team = game_array[0]
        end
        array = [home_team.team_id, away_team.goals]
        away_array = [away_team.team_id, home_team.goals]
        defense_tracker << array
        defense_tracker << away_array
      end
    end
    defense_tracker.each do |score_outcome|
      win_tracker[score_outcome [0]] += score_outcome[1]
    end
    team = win_tracker.max_by do |team_id, goals_against|
      goals_against
    end
    team = team[0]
    convert_team_id_and_team_name(team)
  end
end
