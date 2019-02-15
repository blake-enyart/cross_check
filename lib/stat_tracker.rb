require './lib/class_helper'

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
    game_teams_data = read_game_teams_file(locations[:game_teams])
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

  def self.read_game_teams_file(game_teams_file)
    game_teams = read_in_csv(game_teams_file)
    game_teams.map { |row| GameTeam.new(row) }
  end

  def average_goals_per_game
    average = games.sum do |game|
      (game.away_goals + game.home_goals) / games.count.to_f
    end
    average.round(2)
  end

  def count_of_teams
    teams.length
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

  #League Statistics
  def best_offense
    hash = all_goals_per_team

    best_team_id = hash.max_by { |team_id, team_goals| team_goals }[0]
    convert_team_id_and_team_name(best_team_id)
  end

  def worse_offense
    hash = all_goals_per_team

    worst_team_id = hash.min_by { |team_id, team_goals| team_goals }[0]
    convert_team_id_and_team_name(worst_team_id)
  end

  def all_goals_per_team
    hash = {}
    @teams_hash.each do |team_id, games_array|
      team_goals = 0
      games_array.each do |game|
        team_goals += game.goals.to_i
      end
      hash[team_id] = team_goals
    end
    hash
  end

  
end
