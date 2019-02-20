require_relative './class_helper'

class StatTracker

  attr_reader :games,
              :teams,
              :game_teams,
              :games_home,
              :games_away,
              :preseason_games,
              :regular_games,
              :game_team_pairs

  def initialize(games_data, teams_data, game_teams_data)
    @games = games_data
    @teams = teams_data
    @game_teams = game_teams_data

    separate_games = separate_home_and_away_games(game_teams_data)
    @games_home = separate_games[0]
    @games_away = separate_games[1]
    @teams_hash = group_by_team_id(game_teams_data)

    diff_seasons = separate_pre_and_regular_season_games(games_data)
    @preseason_games = diff_seasons[0]
    @regular_games = diff_seasons[1]

    @game_team_pairs = group_game_team_objects(game_teams_data)
  end

  def group_game_team_objects(game_teams_data)
    sort_game_teams = @game_teams.sort_by(&:game_id)

    game_grouping = []
    sort_game_teams.each_with_index do |game_team, index|
      if sort_game_teams[index+1] != nil
        if game_team.game_id == sort_game_teams[index+1].game_id
          game_grouping << [game_team, sort_game_teams[index+1]]
        end
      end
    end
    game_grouping
  end

  def separate_pre_and_regular_season_games(games_data)
    preseason = []
    regular = []
    games_data.each do |game|
      if game.type == "P"
        preseason << game
      elsif game.type == "R"
        regular << game
      end
    end
    [preseason, regular]
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

    (number_of_wins/number_of_games).round(2)
  end

  def percentage_visitor_wins
    number_of_games = @games_away.size.to_f
    number_of_wins = 0
    @games_away.each do |away_game|
      number_of_wins += 1 if away_game.won == "TRUE"
    end

    (number_of_wins/number_of_games).round(2)
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

  def average_goals_by_season
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
    hash = all_goals_per_team(group_by_team_id(@game_teams))
    best_team_id = hash.max_by { |team_id, team_goals| team_goals }[0]
    convert_team_id_and_team_name(best_team_id)
  end

  def worst_offense
    hash = all_goals_per_team(group_by_team_id(@game_teams))
    worst_team_id = hash.min_by { |team_id, team_goals| team_goals }[0]
    convert_team_id_and_team_name(worst_team_id)
  end

  def all_goals_per_team(teams_hash)
    hash = {}
    teams_hash.each do |team_id, games_array|
      team_goals = 0
      total_games = games_array.size
      games_array.each do |game|
        team_goals += game.goals.to_i
      end
      average_goals_per_game = (team_goals.to_f/total_games).round(2)
      hash[team_id] = average_goals_per_game
    end
    hash
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

  def game_pairs_by_attribute(game_grouping ,attr_sym)
    gp_by_attr = Hash.new { |hash, key| hash[key] = [] }
    game_grouping.each do |game_pair|
      gp_by_attr[game_pair[0].send(attr_sym)] << game_pair
      gp_by_attr[game_pair[1].send(attr_sym)] << game_pair
    end
    gp_by_attr
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
    opposing_team_by_won.each do |team_id, opposing_team_info|
      total_games = opposing_team_info.length
      total_wins = opposing_team_info.count do |info|
        info[1] == "FALSE"
      end
      total_wins_and_games_hash[team_id] = (total_wins.to_f / total_games.to_f).round(2)
    end
    final_hash = {}
    total_wins_and_games_hash.each do |team_id, win_percentage|
      final_hash[convert_team_id_and_team_name(team_id)] = win_percentage
    end
    final_hash
  end

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
end
