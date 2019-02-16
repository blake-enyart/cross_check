require './test/test_helper'


class TeamTest < Minitest::Test

  def setup

    @team = Team.new(team_id: "1", franchiseid:"23", shortname:"New Jersey", teamname:"Devils", abbreviation:"NJD", link:"/api/v1/teams/1")
  end

  def test_it_exists
    assert_instance_of Team, @team
  end

  def test_it_has_attributes
    assert_equal "1", @team.team_id
    assert_equal "23", @team.franchise_id
    assert_equal "New Jersey", @team.short_name
    assert_equal "Devils", @team.team_name
    assert_equal "NJD", @team.abbreviation
    assert_equal "/api/v1/teams/1", @team.link
  end
end
