#require './test/testhelper'
require './lib/team'
require 'minitest/pride'
require 'minitest/autorun'

class TeamTest < Minitest::Test

  def setup
    @team = Team.new(3)
  end

  def test_it_exists
    assert_instance_of Team, @team
  end

end
