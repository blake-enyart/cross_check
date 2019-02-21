require './test/test_helper'

class GameStatsTest < Minitest::Test

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

  def test_highest_total_score_returned

    assert_equal 9, @stat_tracker.highest_total_score
  end

  def test_lowest_total_score_returned

    assert_equal 1, @stat_tracker.lowest_total_score
  end

  def test_biggest_blowout_returns_correct_difference

    assert_equal 5, @stat_tracker.biggest_blowout
  end

  def test_percentage_home_wins_returns_correctly

    assert_equal 0.63, @stat_tracker.percentage_home_wins
  end

  def test_percentage_visitor_wins_returns_correctly

    assert_equal 0.40, @stat_tracker.percentage_visitor_wins
  end

  def test_count_of_games_by_season_returns_correct_hash
    expected = {'20122013' => 8, '20132014' => 12}

    assert_equal expected, @stat_tracker.count_of_games_by_season
  end

  def test_it_can_calculate_total_goals_for_a_given_game_array

    assert_equal 103, @stat_tracker.total_goals(@stat_tracker.games)
  end

  def test_average_goals_per_game_returns_correctly

    assert_equal 5.15, @stat_tracker.average_goals_per_game
  end

  def test_it_can_calculate_average_goals_by_season
    expected = {"20122013"=>5.5, "20132014"=>4.92}
    
    assert_equal expected, @stat_tracker.average_goals_by_season
  end
end
