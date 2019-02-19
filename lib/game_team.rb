class GameTeam

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
              :takeaways,
              :season

  def initialize(row, game_id_season_link)
    @game_id = row[:game_id]
    @team_id = row[:team_id]
    @hoa = row[:hoa]
    @won = row[:won]
    @settled_in = row[:settled_in]
    @head_coach = row[:head_coach]
    @goals = row[:goals].to_i
    @shots = row[:shots].to_i
    @hits = row[:hits].to_i
    @pim = row[:pim]
    @powerplayopportunities = row[:powerplayopportunities].to_i
    @powerplaygoals = row[:powerplaygoals].to_i
    @faceoffwinpercentage = row[:faceoffwinpercentage].to_f
    @giveaways = row[:giveaways].to_i
    @takeaways = row[:takeaways].to_i
    @season = recursive_binary_search(@game_id, game_id_season_link)
  end

  def recursive_binary_search(game_id, game_id_season_link, min_index=0, max_index=game_id_season_link.size-1)
    mid_index = (min_index+max_index)/2
    case game_id_season_link[mid_index][0][0..3].to_i <=> game_id[0..3].to_i
    when 0 #game_id_season_link[mid_index][0][0..3].to_i == game_id[0..3].to_i
        game_id_season_link[mid_index][1]
    when -1 #game_id_season_link[mid_index][0][0..3].to_i < game_id[0..3].to_i
      min_index = mid_index + 1
      recursive_binary_search(game_id, game_id_season_link, min_index, max_index)
    when 1 #game_id_season_link[mid_index][0][0..3].to_i > game_id[0..3].to_i
      max_index = mid_index - 1
      recursive_binary_search(game_id, game_id_season_link, min_index, max_index)
    end
  end
end
