class PagesController < ApplicationController

  require 'open-uri'
  require 'json'

  def game
    @grid = generate_grid(8)
    @start_time = Time.now
  end

  def score
    @end_time = Time.now
    @time = (@end_time - Time.parse(params[:start_time]))
    @name = params[:query]
    @translation = get_translation(@name)
    @score, @message = score_and_message(@name, @translation, params[:grid], @time)
  end

  def home
  end

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
  end

  def get_translation(word)
    response = open("http://api.wordreference.com/0.8/80143/json/enfr/#{word.downcase}")
    json = JSON.parse(response.read.to_s)
    json['term0']['PrincipalTranslations']['0']['FirstTranslation']['term'] unless json["Error"]
  end

  def included?(guess, grid)
  guess.split("").all? { |letter| grid.include? letter }
  end

  def compute_score(attempt, time_taken)
  (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def score_and_message(attempt, translation, grid, time)
    if translation
      if included?(attempt.upcase, grid)
        score = compute_score(attempt, time)
        [score, "Well done"]
      else
        [0, "Not in the grid"]
      end
    else
      [0, "Not an english word"]
    end
  end

end
