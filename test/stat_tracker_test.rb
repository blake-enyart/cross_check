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

  def test_highest_total_score_returned

    assert_equal 9, @stat_tracker.highest_total_score
  end

  def test_lowest_total_score_returned

    assert_equal 1, @stat_tracker.lowest_total_score
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

  def test_it_can_calculate_average_goals_by_season
    assert_equal ({"20122013"=>5.5, "20132014"=>4.92}), @stat_tracker.average_goals_by_season
  end

  def test_it_can_calculate_total_goals_for_a_given_game_array
    assert_equal 103, @stat_tracker.total_goals(@stat_tracker.games)
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

  #Iteration 4 test
  def test_team_info_returns_attributes_in_hash
    expected = {"team_id"=>"6", "franchise_id"=>"6", "short_name"=>"Boston", "team_name"=>"Bruins", "abbreviation"=>"BOS", "link"=>"/api/v1/teams/6"}


    assert_equal expected, @stat_tracker.team_info("6")
  end

  def test_worst_season_returns_correctly

    assert_equal "20132014", @stat_tracker.worst_season("3")
  end

  def test_it_can_find_most_goals_scored_for_a_particular_team

    assert_equal 6, @stat_tracker.most_goals_scored("17")
  end

  def test_it_can_find_fewest_goals_scored_for_a_particular_team

    assert_equal 0, @stat_tracker.fewest_goals_scored("17")
  end

  def test_it_returns_best_defense

    assert_equal "Red Wings", @stat_tracker.best_defense
  end


  def test_it_returns_worst_loss

    assert_equal 5, @stat_tracker.worst_loss("17")
    assert_equal 3, @stat_tracker.worst_loss("6")
  end

  def test_it_returns_biggest_blowout

    assert_equal 3, @stat_tracker.biggest_team_blowout("17")
    assert_equal 5, @stat_tracker.biggest_team_blowout("6")
  end

  def test_it_can_compile_seasonal_summary

  expected = {
    "20122013" => {
      :preseason => {
        :win_percentage=>0.0,
        :total_goals_scored=>0,
        :total_goals_against=>0,
        :average_goals_scored=>0.0,
        :average_goals_against=>0.0
      },
      :regular_season => {
        :win_percentage=>0.33,
        :total_goals_scored=>9,
        :total_goals_against=>9,
        :average_goals_scored=>3.0,
        :average_goals_against=>3.0
        }
      },
      "20132014" => {
        :preseason => {
          :win_percentage=>0.0,
          :total_goals_scored=>0,
          :total_goals_against=>0,
          :average_goals_scored=>0.0,
          :average_goals_against=>0.0
        },
        :regular_season => {
          :win_percentage=>0.67,
          :total_goals_scored=>18,
          :total_goals_against=>16,
          :average_goals_scored=>3.0,
          :average_goals_against=>2.67
        }
      }
    }

    assert_equal expected, @stat_tracker.seasonal_summary("6")
  end

  def test_win_percentage_seasonal_summary

    assert_equal 0.51, @stat_tracker.win_percentage_seasonal_summary(@stat_tracker.game_teams)
  end

  def test_total_goals_scored

    assert_equal 100, @stat_tracker.total_goals_scored_ss(@stat_tracker.game_teams)
  end

  def test_average_goals_scored_ss

    assert_equal 2.56, @stat_tracker.average_goals_scored_ss(@stat_tracker.game_teams)
  end

  def test_total_goals_against

    assert_equal 85, @stat_tracker.total_goals_against_ss(@stat_tracker.game_teams, "6")
  end

  def test_average_goals_against_ss

    assert_equal 2.18, @stat_tracker.average_goals_against_ss(@stat_tracker.game_teams, "6")
  end

  def test_average_win_percentage_returns_correctly

    assert_equal 0.68, @stat_tracker.average_win_percentage("6")
    assert_equal 0.27, @stat_tracker.average_win_percentage("3")
  end

  def test_favorite_opponent_returns_correctly

    assert_equal "Rangers", @stat_tracker.favorite_opponent("6")
  end

  def test_rival_returns_correctly
    skip
    assert_equal "Red Wings", @stat_tracker.rival("6")
  end

  def test_rival_returns_correctly_large_data
    game_path = './data/game.csv'
    team_path = './data/team_info.csv'
    game_teams_path = './data/game_teams_stats.csv'

    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }

    stat_tracker = StatTracker.from_csv(locations)


    assert_equal "Red Wings", stat_tracker.rival("18")
  end

  def test_name_of_team_with_most_hits_returned_large_data
    skip
    game_path = './data/game.csv'
    team_path = './data/team_info.csv'
    game_teams_path = './data/game_teams_stats.csv'

    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }

    stat_tracker = StatTracker.from_csv(locations)

    assert_equal "Islanders", stat_tracker.most_hits("20142015")
  end

  def test_it_can_calculate_head_to_head
    expected = {
      "Rangers" => 0.73,
      "Red Wings" => 0.63
    }
    assert_equal expected, @stat_tracker.head_to_head("6")
  end
end
