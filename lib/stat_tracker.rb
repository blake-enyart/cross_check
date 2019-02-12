
class StatTracker

  attr_reader :games,
              :teams,
              :game_teams

  def initialize(games_data, teams_data, game_teams_data)
    @games = games_data
    @teams = teams_data
    @game_teams = game_teams_data
    # @game_stats = GameStats.new(@games,@teams,@game_teams)
    # @league_stats = LeagueStats.new(@games,@teams,@game_teams)
    # @team_stats = TeamStats.new(@games,@teams,@game_teams)
    # @season_stats = SeasonStats.new(@games,@teams,@game_teams)
  end

  def self.from_csv(locations)
    games_data = self.read_game_file(locations[:games])
    teams_data = self.read_team_file(locations[:teams])
    game_teams_data = self.read_game_teams_file(locations[:game_teams])
    StatTracker.new(games_data, teams_data, game_teams_data)
  end

  def self.read_game_file(game_file)
    games = CSV.open(game_file, headers: true, header_converters: :symbol)
    games.map do |row|
      Game.new(row)
    end
  end

  def self.read_team_file(team_file)
    teams = CSV.open(team_file, headers: true, header_converters: :symbol)
    teams.map do |row|
      Team.new(row)
    end
  end

  def self.read_game_teams_file(game_teams_file)
    game_teams = CSV.open(game_teams_file, headers: true, header_converters: :symbol)
    game_teams.map do |row|
      GameTeam.new(row)
    end
  end
end
