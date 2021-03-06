require_relative './class_helper'
require_relative './season_stats'
require_relative './team_stats'
require_relative './game_stats'
require_relative './league_stats'

class StatTracker
  include SeasonStats
  include TeamStats
  include GameStats
  include LeagueStats

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

  def group_game_teams_by_team_id
    @game_teams.group_by do |game_team|
      game_team.team_id
    end
  end

  def game_pairs_by_attribute(game_grouping ,attr_sym)
    gp_by_attr = Hash.new { |hash, key| hash[key] = [] }
    game_grouping.each do |game_pair|
      gp_by_attr[game_pair[0].send(attr_sym)] << game_pair
      gp_by_attr[game_pair[1].send(attr_sym)] << game_pair
    end
    gp_by_attr
  end
end
