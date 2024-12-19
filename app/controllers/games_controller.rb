require 'open-uri'
require 'json'
require 'time'

class GamesController < ApplicationController
  def new
    @letters = []
    vowels = ["A", "E", "I", "O", "U"]
    cons = ("A".."Z").to_a
    8.times { @letters << (cons - vowels).sample }
    2.times { @letters << vowels.sample }
    @letters.shuffle!
    @start = Time.now
  end

  def score
    finish = Time.now
    start = Time.parse(params[:start])
    total = finish - start
    word = params[:word]
    letters = params[:letters].split(" ")

    score_and_message = score_and_message(word, letters, total)
    @score = score_and_message.first
    @message = score_and_message.last
  end

  private

  def check_grid(answer, grid)
    answer.chars.all? { |letter| answer.count(letter) <= grid.count(letter) }
  end

  def calc_score(word, time)
    time > 60.0 ? 0 : (word.size * (1.0 - (time / 60.0)))
  end

  def english_word?(word)
    data = URI.parse("https://dictionary.lewagon.com/#{word}")
    json = JSON.parse(data.read)
    return json['found']
  end

  def score_and_message(word, grid, time)
    if check_grid(word.upcase, grid)
      if english_word?(word)
        score = calc_score(word, time)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end
end
