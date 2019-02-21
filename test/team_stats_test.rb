require 'minitest/autorun'
require 'minitest/pride'
require 'pry'
require './lib/stat_tracker'

class TeamStatsTest < Minitest::Test

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

  def test_worst_season_returns_correctly
    assert_equal "20132014", @stat_tracker.worst_season("3")
  end

  def test_it_can_find_most_goals_scored_for_a_particular_team
    assert_equal 6, @stat_tracker.most_goals_scored("17")
  end

  def test_it_can_find_fewest_goals_scored_for_a_particular_team
    assert_equal 0, @stat_tracker.fewest_goals_scored("17")
  end

  def test_team_info_returns_attributes_in_hash
    expected = {"team_id"=>"6", "franchise_id"=>"6", "short_name"=>"Boston", "team_name"=>"Bruins", "abbreviation"=>"BOS", "link"=>"/api/v1/teams/6"}
    assert_equal expected, @stat_tracker.team_info("6")
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

  def test_it_can_calculate_head_to_head
    expected = {
      "Rangers" => 0.73,
      "Red Wings" => 0.63
    }
    assert_equal expected, @stat_tracker.head_to_head("6")
  end


end
