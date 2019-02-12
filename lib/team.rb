class Team
  attr_reader :team_id, :franchiseId, :shortName, :teamName, :abbreviation, :link

  def initialize(row)
    @team_id = row[:team_id]
    @franchiseId = row[:franchiseId]
    @shortName = row[:shortName]
    @teamName = row[:teamName]
    @abbreviation = row[:abbreviation]
    @link = row[:link]
  end

  
end
