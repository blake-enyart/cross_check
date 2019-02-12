require './test/test_helper'

class StatTrackerTest < Minitest::Test

  def setup
    @stat_tracker = StatTracker.new
  end

  def test_it_exist

    assert_instance_of StatTracker, @stat_tracker
  end

  def test_from_game_csv_extracts_line
    game_path = './data/game.csv'
    team_path = './data/team_info.csv'
    game_teams_path = './data/game_teams_stats.csv'

    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }

    assert_equal Game, StatTracker.from_csv(locations).game_line
  end
end
