module GameStats

  def highest_total_score
    total_score = []
    @games.each do |game|
      total_score << (game.away_goals.to_i + game.home_goals.to_i)
    end
    total_score.max
  end

  def lowest_total_score
    total_score = []
    @games.each do |game|
      total_score << (game.away_goals.to_i + game.home_goals.to_i)
    end
    total_score.min
  end

  def biggest_blowout
    blowout = 0
    @games.each do |game|
      difference = (game.away_goals.to_i - game.home_goals.to_i).abs
      if difference > blowout
        blowout = difference
      end
    end
    blowout
  end

  def percentage_home_wins
    number_of_games = @games_home.size.to_f
    number_of_wins = 0
    @games_home.each do |home_game|
      number_of_wins += 1 if home_game.won == "TRUE"
    end

    (number_of_wins/number_of_games).round(2)
  end

  def percentage_visitor_wins
    number_of_games = @games_away.size.to_f
    number_of_wins = 0
    @games_away.each do |away_game|
      number_of_wins += 1 if away_game.won == "TRUE"
    end

    (number_of_wins/number_of_games).round(2)
  end

  def count_of_games_by_season
    hash = @games.group_by { |game| game.season }
    hash.each do |season, game_array|
      hash[season] = game_array.count
    end
    hash
  end

  def average_goals_per_game
    (total_goals(@games)/@games.count).round(2)
  end

  def total_goals(games_array)
    games_array.sum do |game|
      (game.away_goals + game.home_goals).to_f
    end
  end

  def average_goals_by_season
    goals_per_season_hash = {}
    games_by_season.each do |season_key, games_array|
      goals_per_season_hash[season_key] = (total_goals(games_array) / games_array.count).round(2)
    end
    goals_per_season_hash
  end

  def games_by_season
    @games.group_by do |game|
      game.season
    end
  end
end
