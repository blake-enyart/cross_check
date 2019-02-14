require './test/test_helper/'

class GameTest < Minitest::Test

  def setup
    game_path = './data/samples/game.csv'
    team_path = './data/samples/team_info.csv'
    game_teams_path = './data/samples/game_teams_stats.csv'

    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }
    row = StatTracker.read_in_csv(locations[:games]).readline
    @game = Game.new(row)
  end

  def test_it_exists
    assert_instance_of Game, @game
  end

  def test_it_has_attributes
    assert_equal "2012030221", @game.game_id
    assert_equal "20122013", @game.season
    assert_equal "P", @game.type
    assert_equal "2013-05-16", @game.date_time
    assert_equal "3", @game.away_team_id
    assert_equal "6", @game.home_team_id
    assert_equal 2, @game.away_goals
    assert_equal 3, @game.home_goals
    assert_equal "home win OT", @game.outcome
    assert_equal "left", @game.home_rink_side_start
    assert_equal "TD Garden", @game.venue
    assert_equal "/api/v1/venues/null", @game.venue_link
    assert_equal "America/New_York", @game.venue_time_zone_id
    assert_equal "-4", @game.venue_time_zone_offset
    assert_equal "EDT", @game.venue_time_zone_tz
  end

end
