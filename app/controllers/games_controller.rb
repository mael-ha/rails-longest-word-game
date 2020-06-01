require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @grid_size = params[:grid_size].to_i
    grid_generate(@grid_size)
    @start_time = Time.now

  end

  def score
    @start_time = Time.parse(params[:start_time])
    @end_time = Time.now
    @attempt = params[:attempt]
    @grid = params[:grid]
    @result = run_game(@attempt, @grid, @start_time, @end_time)
  end

  # private

  def grid_generate(grid_size)
    grid = Array.new(grid_size, "A")
    @grid = grid.map do |a|
      ('A'..'Z').to_a.sample
    end
    return @grid
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    # store the information from the game:
    result = {
      time: 0,
      score: 0,
      message: ""
    }
    # calcuate time for the match
    attempt_time = end_time.to_i - start_time.to_i
    result[:time] = attempt_time
    # change the attempt into an array of letters
    a_attempt = attempt.upcase.split('')
    # Word existe ? check word in html
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    response = open(url).read
    data = JSON.parse(response)
    if data["found"]
      if words_match?(a_attempt, grid)
       result[:message] = "well done!"
       result[:score] = score_result(grid, attempt, attempt_time)
      else
       result[:message] = "Fail ! Not in the grid!!"
       result[:score] = 0
      end
    else # word don't exist
     result[:message] = "Fail ! not an english word"
     result[:score] = 0
    end
    return result
  end

  def score_result(grid, attempt, attempt_time)
    if attempt_time < 5
      return attempt.length.fdiv(grid.length) * 4 + 5
    else
      return attempt.length.fdiv(grid.length) * 4
    end
  end

  def words_match?(a_attempt, grid)
    # Create hash with frequency of each letters for a_attempt and grid
    hash_attempt = a_attempt.group_by(&:itself).transform_values(&:count)
    hash_grid = grid.split(" ").group_by(&:itself).transform_values(&:count)
    matching_array = []
    hash_attempt.each do |letter, frequency|
      # Check if the letter is present in both hash
      if hash_grid.key?(letter)
        # Check if the frequency of each matching letter in attempt <= frequency of the letter in grid
        if frequency <= hash_grid[letter]
          matching_array << true
        else
          matching_array << false
        end
      else
        matching_array << false
      end
    end
    # return true only if ALL true in matching_array
    if matching_array.all? { |item| item == true }
      return true
    else
      return false
    end
  end

end
