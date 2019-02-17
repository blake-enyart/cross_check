require_relative './class_helper'

class StatTracker

  attr_reader :games,
              :teams,
              :game_teams,
              :games_home,
              :games_away

  def initialize(games_data, teams_data, game_teams_data)
    @games = games_data
    @teams = teams_data
    @game_teams = game_teams_data
    @games_home = separate_home_and_away_games(game_teams_data)[0]
    @games_away = separate_home_and_away_games(game_teams_data)[1]
    @teams_hash = group_by_team_id(game_teams_data)
  end

  def group_by_team_id(game_teams_data)
    game_teams_data.group_by { |row| row.team_id }
  end

  def separate_home_and_away_games(game_teams_data)
    home_games = []
    away_games = []
    game_teams_data.each do |row|
      if row.hoa == 'home'
        home_games << row
      elsif row.hoa == 'away'
        away_games << row
      end
    end
    [home_games, away_games]
  end

  def convert_team_id_and_team_name(team)
    name = nil
    @teams.each do |row|
      if team == row.team_id
        name = row.team_name
      elsif team == row.team_name
        name = row.team_id
      end
    end
    name
  end

  def self.from_csv(locations)
    games_data = read_game_file(locations[:games])
    teams_data = read_team_file(locations[:teams])
    game_teams_data = read_game_teams_file(locations[:game_teams], games_data)
    StatTracker.new(games_data, teams_data, game_teams_data)
  end

  def self.read_in_csv(file_path)
    CSV.open(file_path, headers: true, header_converters: :symbol)
  end

  def self.read_game_file(game_file)
    games = read_in_csv(game_file)
    games.map { |row| Game.new(row) }
  end

  def self.read_team_file(team_file)
    teams = read_in_csv(team_file)
    teams.map { |row| Team.new(row) }
  end

  def self.read_game_teams_file(game_teams_file, games_data)
    game_teams = read_in_csv(game_teams_file)

    game_id_season_link = games_data.map do |game|
      [game.game_id, game.season]
    end.sort_by { |pair| pair[0].to_i }

    game_teams.map { |row| GameTeam.new(row, game_id_season_link) }
  end

  def total_goals(games_array)
    games_array.sum do |game|
      (game.away_goals + game.home_goals).to_f
    end
  end

  def average_goals_per_game
    (total_goals(@games)/@games.count).round(2)
  end

  def count_of_teams
    @teams.length
  end

  def biggest_blowout
    blowout = 0
    @games.each do |game|
      difference = (game.away_goals.to_i - game.home_goals.to_i).abs
      if difference > blowout
        blowout = difference
      end
    end
    blowout
  end

  def highest_total_score
    total_score = []
    @games.each do |game|
      total_score << (game.away_goals.to_i + game.home_goals.to_i)
    end
    total_score.max
  end

  def lowest_total_score
    total_score = []
    @games.each do |game|
      total_score << (game.away_goals.to_i + game.home_goals.to_i)
    end
    total_score.min
  end

  def percentage_home_wins
    number_of_games = @games_home.size.to_f
    number_of_wins = 0
    @games_home.each do |home_game|
      number_of_wins += 1 if home_game.won == "TRUE"
    end

    percent_wins = (number_of_wins/number_of_games)*100
    percent_wins.round(2)
  end

  def percentage_visitor_wins
    number_of_games = @games_away.size.to_f
    number_of_wins = 0
    @games_away.each do |away_game|
      number_of_wins += 1 if away_game.won == "TRUE"
    end

    percent_wins = (number_of_wins/number_of_games)*100
    percent_wins.round(2)
  end

  def count_of_games_by_season
    hash = @games.group_by { |game| game.season }
    hash.each do |season, game_array|
      hash[season] = game_array.count
    end
    hash
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

  def group_game_teams_by_team_id
    @game_teams.group_by do |game_team|
      game_team.team_id
    end
  end

  def average_goals_per_season
    goals_per_season_hash = {}
    games_by_season.each do |season_key, games_array|
      goals_per_season_hash[season_key] = (total_goals(games_array) / games_array.count).round(2)
    end
    goals_per_season_hash
  end

  def games_by_season
    @games.group_by do |game|
      game.season
    end
  end

  #League Statistics
  def best_offense
    hash = all_goals_per_team(@teams_hash)

    best_team_id = hash.max_by { |team_id, team_goals| team_goals }[0]
    convert_team_id_and_team_name(best_team_id)
  end

  def worse_offense
    hash = all_goals_per_team(@teams_hash)

    worst_team_id = hash.min_by { |team_id, team_goals| team_goals }[0]
    convert_team_id_and_team_name(worst_team_id)
  end

  def all_goals_per_team(teams_hash)
    hash = {}
    teams_hash.each do |team_id, games_array|
      team_goals = 0
      games_array.each do |game|
        team_goals += game.goals.to_i
      end
      hash[team_id] = team_goals
    end
    hash
  end

  def highest_scoring_visitor
    sorted_away_games = group_by_team_id(@games_away)
    sorted_with_scores = all_goals_per_team(sorted_away_games)

    best_team_id = sorted_with_scores.max_by { |team_id, team_goals| team_goals }[0]
    convert_team_id_and_team_name(best_team_id)
  end

  def highest_scoring_home_team
    sorted_home_games = group_by_team_id(@games_home)
    sorted_with_scores = all_goals_per_team(sorted_home_games)

    best_team_id = sorted_with_scores.max_by { |team_id, team_goals| team_goals }[0]
    convert_team_id_and_team_name(best_team_id)
  end

  def lowest_scoring_visitor
    sorted_away_games = group_by_team_id(@games_away)
    sorted_with_scores = all_goals_per_team(sorted_away_games)

    worst_team_id = sorted_with_scores.min_by { |team_id, team_goals| team_goals }[0]
    convert_team_id_and_team_name(worst_team_id)
  end

  def lowest_scoring_home_team
    sorted_home_games = group_by_team_id(@games_home)
    sorted_with_scores = all_goals_per_team(sorted_home_games)

    worst_team_id = sorted_with_scores.min_by { |team_id, team_goals| team_goals }[0]
    convert_team_id_and_team_name(worst_team_id)
  end

  def winningest_team
    win_tracker = @teams_hash
    win_tracker = win_tracker.each { |k,v| win_tracker[k] = 0 }

    game_grouping = @game_teams.group_by { |row| row.game_id }
    game_grouping.each do |game_id, game_array|
      outcome = win_determination(game_array)
      if outcome
        win_tracker[outcome[0]] += outcome[1]
      end
    end

    best_team_id = win_tracker.max_by { |team_id, wins| wins }[0]
    convert_team_id_and_team_name(best_team_id)
  end

  def win_determination(game_array)
    if game_array.length == 2
      if game_array[0].hoa == 'home'
        home_team = game_array[0]
        away_team = game_array[1]
      else
        home_team = game_array[1]
        away_team = game_array[0]
      end

      if home_team.goals > away_team.goals
        [home_team.team_id, 1]
      else
        [away_team.team_id, 1]
      end
    end
  end

  def best_defense
    win_tracker = @teams_hash
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
    win_tracker = @teams_hash
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
    most_goals = @teams_hash[team_id].max_by do |game_team|
      game_team.goals
    end
    most_goals.goals
  end

  def fewest_goals_scored(team_id)
    fewest_goals = @teams_hash[team_id].min_by do |game_team|
      game_team.goals
    end
    fewest_goals.goals
  end

  def team_info(team_id)
    hash = {}
    @teams.each do |team|
      if team.team_id == team_id
        team.instance_variables.each do |variable|
          hash[variable] = team.instance_variable_get(variable)
        end
      end
    end
    hash
  end

  def worst_loss
    #Biggest difference between team goals and opponent goals for a loss
    #for the given team.
  end

  def biggest_team_blowout
    #Biggest difference between team goals and opponent goals for a win
    # for the given team.
  end

  def average_win_percentage(team_id)
    games_for_team = @teams_hash[team_id]
    sort = sort_game_team_pairs_by_attribute_and_select(:team_id, team_id)
    total_games = sort[team_id].size

    total_wins = wins_for_team(sort[team_id], team_id)
    average_win = (total_wins.to_f/total_games)*100
    average_win.round(2)
  end
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

  hash = Hash.new { |hash, key| hash[key] = [] }
  game_grouping.each do |game_pair|
    if game_pair[0].send(attr_sym) == selection || game_pair[1].send(attr_sym) == selection
      hash[selection] << game_pair
    end
  end

  hash
end
