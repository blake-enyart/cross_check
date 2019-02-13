require './test/test_helper/'

class GameTest < Minitest::Test

  def setup
    game_path = './data/game_dummy.csv'
    team_path = './data/team_info_dummy.csv'
    game_teams_path = './data/game_teams_stats_dummy.csv'
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
    assert_equal "2", @game.away_goals
    assert_equal "6", @game.home_team_id
  end

end
