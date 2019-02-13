require './test/test_helper'


class TeamTest < Minitest::Test

  def setup
    game_path = './data/samples/game.csv'
    team_path = './data/samples/team_info.csv'
    game_teams_path = './data/samples/game_teams_stats.csv'
    
    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }
    row = StatTracker.read_in_csv(locations[:teams]).readline
    @team = Team.new(team_id: "1", franchiseId:"23", shortName:"New Jersey", teamName:"Devils", abbreviation:"NJD", link:"/api/v1/teams/1")
  end

  def test_it_exists
    assert_instance_of Team, @team
  end

  def test_it_has_attributes
    assert_equal "1", @team.team_id
    assert_equal "23", @team.franchiseId
    assert_equal "New Jersey", @team.shortName
    assert_equal "Devils", @team.teamName
    assert_equal "NJD", @team.abbreviation
    assert_equal "/api/v1/teams/1", @team.link
  end
end
