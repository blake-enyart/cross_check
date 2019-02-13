class Record
  def self.all
    @all
  end

  def self.create(row)
    record = new(row)

    if @all
      @all << record
    else
      @all = [record]
    end
  end
end

class GameTeam < Record
  attr_reader :game_id,
              :team_id,
              :hoa,
              :won,
              :settled_in,
              :head_coach,
              :goals,
              :shots,
              :hits,
              :pim,
              :powerplayopportunities,
              :powerplaygoals,
              :faceoffwinpercentage,
              :giveaways,
              :takeaways

  def initialize(row)
    @game_id = row[:game_id]
    @team_id = row[:team_id]
    @hoa = row[:hoa]
    @won = row[:won]
    @settled_in = row[:settled_in]
    @head_coach = row[:head_coach]
    @goals = row[:goals]
    @shots = row[:hits]
    @hits = row[:pim]
    @pim = row[:powerplayopportunities]
    @powerplaygoals = row[:powerplaygoals]
    @faceoffwinpercentage = row[:faceoffwinpercentage]
    @giveaways = row[:giveaways]
    @takeaways = row[:takeaways]
  end
end
