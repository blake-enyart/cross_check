require './lib/class_helper'

class StatTracker

  attr_reader :games,
              :teams,
              :game_teams

  def initialize(games_data, teams_data, game_teams_data)
    @games = games_data
    @teams = teams_data
    @game_teams = game_teams_data
    # @game_stats = GameStats.new(@games,@teams,@game_teams)
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
end
