require 'minitest/autorun'
require 'minitest/pride'
require 'pry'
require './lib/stat_tracker'

class SeasonStatsTest < Minitest::Test

  def setup
    game_path = './data/samples/game.csv'
    team_path = './data/samples/team_info.csv'
    game_teams_path = './data/samples/game_teams_stats.csv'

    @locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }

    @stat_tracker = StatTracker.from_csv(@locations)
  end

  def test_name_of_team_with_most_hits_returned

    assert_equal "Rangers", @stat_tracker.most_hits("20122013")
  end

  def test_name_of_team_with_least_hits_returned

    assert_equal "Bruins", @stat_tracker.least_hits("20122013")
  end

  def test_biggest_surprise_returns_correctly
    game_path = './data/game.csv'
    team_path = './data/team_info.csv'
    game_teams_path = './data/game_teams_stats.csv'

    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }

    stat_tracker = StatTracker.from_csv(locations)

    assert_equal "Canucks", stat_tracker.biggest_surprise("20122013")
  end

  def test_biggest_best_returns_correctly
    game_path = './data/game.csv'
    team_path = './data/team_info.csv'
    game_teams_path = './data/game_teams_stats.csv'

    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }

    stat_tracker = StatTracker.from_csv(locations)

    assert_equal "Sharks", stat_tracker.biggest_bust("20122013")
  end



end
