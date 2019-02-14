class Game

  attr_reader :game_id,
              :season,
              :type,
              :date_time,
              :away_team_id,
              :home_team_id,
              :away_goals,
              :home_goals,
              :outcome,
              :home_rink_side_start,
              :venue,
              :venue_link,
              :venue_time_zone_id,
              :venue_time_zone_offset,
              :venue_time_zone_tz

  def initialize(row)
    @game_id = row[:game_id]
    @season = row[:season]
    @type = row[:type]
    @date_time = row[:date_time]
    @away_team_id = row[:away_team_id]
    @home_team_id = row[:home_team_id]
    @away_goals = row[:away_goals].to_i
    @home_goals = row[:home_goals].to_i
    @outcome = row[:outcome]
    @home_rink_side_start = row[:home_rink_side_start]
    @venue = row[:venue]
    @venue_link = row[:venue_link]
    @venue_time_zone_id = row[:venue_time_zone_id]
    @venue_time_zone_offset = row[:venue_time_zone_offset]
    @venue_time_zone_tz = row[:venue_time_zone_tz]
  end

end
