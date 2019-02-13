require './test/test_helper'

class StatTrackerTest < Minitest::Test

  def setup
    @stat_tracker = StatTracker.new()
  end

  def test_it_exist

    assert_instance_of StatTracker, @stat_tracker
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
    game_path = './data/game_dummy.csv'
    team_path = './data/team_info_dummy.csv'
    game_teams_path = './data/game_teams_stats_dummy.csv'

    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }

    assert_equal Team, StatTracker.from_csv(locations).teams[0].class
  end

  def test_from_csv_stores_array_of_game_team_objects
    game_path = './data/game_dummy.csv'
    team_path = './data/team_info_dummy.csv'
    game_teams_path = './data/game_teams_stats_dummy.csv'

    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }

    assert_equal GameTeam, StatTracker.from_csv(locations).game_teams[0].class
  end
end
