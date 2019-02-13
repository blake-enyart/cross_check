[:game_id, :team_id, :hoa, :won, :settled_in, :head_coach, :goals, :shots, :hits, :pim, :powerplayopportunities, :powerplaygoals, :faceoffwinpercentage, :giveaways, :takeaways]
require './test/test_helper'

class GameTeamTest < Minitest::Test

  def setup
    game_path = './data/game_dummy.csv'
    team_path = './data/team_info_dummy.csv'
    game_teams_path = './data/game_teams_stats_dummy.csv'

    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }

    row = StatTracker.read_in_csv(locations[:game_teams]).readline
    @game_team = GameTeam.new(row)
  end

  def test_it_exist

    assert_instance_of GameTeam, @game_team
  end

  def test_attributes_return_correctly

    assert_equal "2012030221", @game_team.game_id
    assert_equal "3", @game_team.team_id
    assert_equal "away", @game_team.hoa
    assert_equal "FALSE", @game_team.won
    assert_equal "OT", @game_team.settled_in
    assert_equal "John Tortorella", @game_team.head_coach
    assert_equal "2", @game_team.goals
    assert_equal "35", @game_team.shots
    assert_equal "44", @game_team.hits
    assert_equal "8", @game_team.pim
    assert_equal "3", @game_team.powerplayopportunities
    assert_equal "0", @game_team.powerplaygoals
    assert_equal "44.8", @game_team.faceoffwinpercentage
    assert_equal "17", @game_team.giveaways
    assert_equal "7", @game_team.takeaways
  end
end
