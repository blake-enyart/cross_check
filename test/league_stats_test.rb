require 'minitest/autorun'
require 'minitest/pride'
require 'pry'
require './lib/stat_tracker'

class LeagueStatsTest < Minitest::Test

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

  def test_it_gets_count_of_teams

    assert_equal 4, @stat_tracker.count_of_teams
  end

  def test_it_can_find_team_with_best_fans

    assert_equal "Bruins", @stat_tracker.best_fans
  end

  def test_it_can_find_team_with_worst_fans

    game_path = './data/samples/game.csv'
    team_path = './data/samples/team_info.csv'
    game_teams_path = './data/samples/game_teams_worst_fans.csv'

    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }
    stat_tracker = StatTracker.from_csv(locations)

    assert_equal ["Rangers","Red Wings"], stat_tracker.worst_fans
  end

  def test_best_offense_returns_correct_team

    assert_equal 'Bruins', @stat_tracker.best_offense
  end

  def test_worst_offense_returns_correct_team

    assert_equal 'Red Wings', @stat_tracker.worst_offense
  end

  def test_highest_scoring_visitor_returns_correctly

    assert_equal "Bruins", @stat_tracker.highest_scoring_visitor
  end

  def test_highest_scoring_home_team_returns_correctly

    assert_equal "Bruins", @stat_tracker.highest_scoring_home_team
  end

  def test_lowest_scoring_visitor_returns_correctly

    assert_equal "Red Wings", @stat_tracker.lowest_scoring_visitor
  end

  def test_lowest_scoring_home_team_returns_correctly

    assert_equal "Rangers", @stat_tracker.lowest_scoring_home_team
  end

  def test_winningest_team_returns_correct_team_large_data
    game_path = './data/game.csv'
    team_path = './data/team_info.csv'
    game_teams_path = './data/game_teams_stats.csv'

    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }

    stat_tracker = StatTracker.from_csv(locations)

    assert_equal "Golden Knights", stat_tracker.winningest_team
  end

  def test_it_returns_best_defense

    assert_equal "Red Wings", @stat_tracker.best_defense
  end

  def test_it_returns_worst_defense_large_data
    game_path = './data/game.csv'
    team_path = './data/team_info.csv'
    game_teams_path = './data/game_teams_stats.csv'

    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }

    stat_tracker = StatTracker.from_csv(locations)

    assert_equal "Islanders", stat_tracker.worst_defense
  end
end
