require './test/test_helper'

class StatTrackerTest < Minitest::Test

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

  def test_it_exists
    game_path = './data/samples/game.csv'
    team_path = './data/samples/team_info.csv'
    game_teams_path = './data/samples/game_teams_stats.csv'

    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }
    stat_tracker = StatTracker.new(locations[:games], locations[:teams], locations[:game_teams])

    assert_instance_of StatTracker, stat_tracker
  end

  def test_from_csv_stores_array_of_game_objects
    game_path = './data/samples/game.csv'
    team_path = './data/samples/team_info.csv'
    game_teams_path = './data/samples/game_teams_stats.csv'

    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }

    assert_equal Game, StatTracker.from_csv(locations).games[0].class
  end

  def test_from_csv_stores_array_of_team_objects
    game_path = './data/samples/game.csv'
    team_path = './data/samples/team_info.csv'
    game_teams_path = './data/samples/game_teams_stats.csv'

    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }

    assert_equal Team, StatTracker.from_csv(locations).teams[0].class
  end

  def test_from_csv_stores_array_of_game_team_objects
    game_path = './data/samples/game.csv'
    team_path = './data/samples/team_info.csv'
    game_teams_path = './data/samples/game_teams_stats.csv'

    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }

    assert_equal GameTeam, StatTracker.from_csv(locations).game_teams[0].class
  end

  def test_biggest_blowout_returns_correct_difference

    assert_equal 5, @stat_tracker.biggest_blowout
  end

  def test_highest_total_score_returned

    assert_equal 9, @stat_tracker.highest_total_score
  end

  def test_lowest_total_score_returned

    assert_equal 1, @stat_tracker.lowest_total_score
  end
end
