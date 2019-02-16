class Team
  attr_reader :team_id, :franchise_id, :short_name, :team_name, :abbreviation, :link

  def initialize(row)
    @team_id = row[:team_id]
    @franchise_id = row[:franchiseid]
    @short_name = row[:shortname]
    @team_name = row[:teamname]
    @abbreviation = row[:abbreviation]
    @link = row[:link]
  end
end
