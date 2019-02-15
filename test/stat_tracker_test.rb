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

    assert_instance_of StatTracker, @stat_tracker
  end

  def test_from_csv_stores_array_of_game_objects

    assert_equal Game, StatTracker.from_csv(@locations).games[0].class
  end

  def test_from_csv_stores_array_of_team_objects

    assert_equal Team, StatTracker.from_csv(@locations).teams[0].class
  end

  def test_from_csv_stores_array_of_game_team_objects

    assert_equal GameTeam, StatTracker.from_csv(@locations).game_teams[0].class
  end

  def test_it_can_calculate_average_goals_per_game

    assert_equal 5.15, @stat_tracker.average_goals_per_game
  end

  def test_it_gets_count_of_teams

    assert_equal 4, @stat_tracker.count_of_teams
  end

  def test_biggest_blowout_returns_correct_difference

    assert_equal 5, @stat_tracker.biggest_blowout
  end

  def test_percentage_home_wins_returns_correctly

    assert_equal 63.16, @stat_tracker.percentage_home_wins
  end

  def test_percentage_visitor_wins_returns_correctly

    assert_equal 40.0, @stat_tracker.percentage_visitor_wins
  end

  def test_count_of_games_by_season_returns_correct_hash
    expected = {'20122013' => 8, '20132014' => 12}

    assert_equal expected, @stat_tracker.count_of_games_by_season
  end

  def test_it_can_calculate_average_goals_by_season
    assert_equal ({"20122013"=>5.5, "20132014"=>4.92}), @stat_tracker.average_goals_per_season
  end

  def test_it_can_calculate_total_goals_for_a_given_game_array
    assert_equal 103, @stat_tracker.total_goals(@stat_tracker.games)
  end

  def test_it_can_get_games_by_season
    assert_equal (['20122013', '20132014']), @stat_tracker.games_by_season.keys
    assert_equal 8, @stat_tracker.games_by_season['20122013'].count
  end

end
