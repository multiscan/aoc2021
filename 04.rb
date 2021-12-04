#!/usr/bin/env ruby

require 'minitest'
require 'minitest/rg'

require './aoc.rb'

class Bingo
  attr_reader :winner, :last
  def initialize(data)
    l = data.lines
    @preset_draw_order = l.shift.split(",").map{|s| s.to_i}
    @ncards = l.count/(Card::N+1)
    @cards = []
    @ncards.times do |i|
      l.shift # empty line
      c = []
      Card::N.times do
        c = c + l.shift.split(" ").map{|s| s.to_i}
      end
      @cards << Card.new(i, c)
    end
    reset
  end
  def reset
    @calls = @preset_draw_order.dup
    @winner = nil
    @cards.each {|c| c.reset}
  end
  def play()
    got_winner=false
    while d=@calls.shift do
      remaining_cards = @cards.select{|c| not c.wins?} 
      remaining_cards.each { |c| c.check(d) }
      w = remaining_cards.find {|c| c.wins? }
      if w
        @winner = w
        @last = d
        # puts "card #{@winner.id} wins with score #{@winner.score} when number #{d} were called"
        return true
      end
    end
    return false
  end
  def last_card
    self.reset
    @winners = []
    @ncards.times do
      self.play
      @winners << @winner
    end
    # p @winners.map{|w| w.id}
    @winners.last
  end
  def score
    return nil unless @winner
    self.last * @winner.score
  end
end

class Card
  attr_reader :score, :id
  N = 5
  def initialize(id, a)
    @id = id
    @card = a
    @card = {}
    a.each_with_index do |n, i|
      @card[n] = i
    end
    reset
  end
  def reset
    @cols = [0] * N
    @rows = [0] * N
    @score = @card.keys.sum
  end
  def check(n)
    if @card.key?(n)
      c = @card[n]
      col = c % N
      row = c / N
      @cols[col] = @cols[col] + 1
      @rows[row] = @rows[row] + 1
      @score = @score - n
    end
  end
  def wins?
    @cols.include?(N) || @rows.include?(N)
  end

end

class BingoTest < MiniTest::Test
  TDATA1="""7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

          22 13 17 11  0
           8  2 23  4 24
          21  9 14 16  7
           6 10  3 18  5
           1 12 20 15 19

           3 15  0  2 22
           9 18 13 17  5
          19  8  7 25 23
          20 11 10 24  4
          14 21 16 12  6

          14 21 17 24  4
          10 16 15  9 19
          18  8 23 26 20
          22 11 13  6  5
           2  0 12  3  7
"""

  TDATA2="""7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

           3 15  0  2 22
           9 18 13 17  5
          19  8  7 25 23
          20 11 10 24  4
          14 21 16 12  6
"""


  def test_play
    b = Bingo.new(TDATA1)
    e = b.play()
    assert_equal true, e
    assert_equal 24, b.last
    assert_equal 188, b.winner.score
    assert_equal 4512, b.score
  end
  def test_play_with_one_card
    b = Bingo.new(TDATA2)
    e = b.play()
    assert_equal true, e
    assert_equal 13, b.last
    assert_equal 148, b.winner.score
    assert_equal 13*148, b.score
  end
  def test_last
    b = Bingo.new(TDATA1)
    lc = b.last_card
    assert_equal 13, b.last
    assert_equal 148, lc.score
  end
end


if MiniTest.run                                # The Run/Kill Switch
  puts "Tests Passed!"
  data = load_data(4)
  b = Bingo.new(data)
  w = b.play()
  if w 
    puts "There is a winner. Score: #{b.score}"
  else
    puts "There is no winner."
  end
  lw = b.last_card
  puts "Last card have score #{lw.score}. Score: #{b.score}"
end
