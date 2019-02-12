require './test/test_helper'

class StatTrackerTest < Minitest::Test

  # def setup
  #   @stat_tracker = StatTracker.new()
  # end

  def test_it_exist
    skip

    assert_instance_of StatTracker, @stat_tracker
  end

  def test_from_game_csv_extracts_line_to_game_object
    game_path = './data/game_dummy.csv'
    team_path = './data/team_info_dummy.csv'
    game_teams_path = './data/game_teams_stats_dummy.csv'

    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }

    assert_equal Game, StatTracker.from_csv(locations).games[0].class
  end
end
