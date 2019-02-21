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


  def test_it_gets_count_of_teams

    assert_equal 4, @stat_tracker.count_of_teams
  end

  def test_it_can_find_team_with_best_fans

    assert_equal "Bruins", @stat_tracker.best_fans
  end

  def test_it_can_find_team_with_worst_fans

    #sample data has no worst_fans team, created game_teams_worst_fans.csv for testing
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

  def test_it_can_create_a_hash_of_game_team_objects_by_team_id

    assert_equal ["3", "6", "17"], @stat_tracker.group_game_teams_by_team_id.keys
    assert_equal "2012030221", @stat_tracker.group_game_teams_by_team_id["3"][0].game_id
  end

  def test_it_can_get_games_by_season
    assert_equal (['20122013', '20132014']), @stat_tracker.games_by_season.keys
    assert_equal 8, @stat_tracker.games_by_season['20122013'].count
  end

  def test_best_offense_returns_correct_team

    assert_equal 'Bruins', @stat_tracker.best_offense
  end

  def test_worst_offense_returns_correct_team

    assert_equal 'Red Wings', @stat_tracker.worst_offense
  end

  def test_it_returns_biggest_team_blowout

    assert_equal 3, @stat_tracker.biggest_team_blowout("17")
    assert_equal 5, @stat_tracker.biggest_team_blowout("6")
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
end
