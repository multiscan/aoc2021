#!/usr/bin/env ruby
require 'minitest'
require 'minitest/rg'

require './aoc.rb'

class DeterministicDice
  def initialize
    @c=0
    @n=0
  end
  def roll
    r = @c + 1
    @c = (@c + 1)%100
    @n = @n + 1
    r
  end
  def nrols
    @n
  end
end

class Player
  def initialize(l)
    # Player 1 starting position: 4
    m = /^Player ([0-9]+) starting position: ([0-9]+)$/.match(l.chomp)
    puts "Player::init m=#{m.inspect}"
    p0 = m[2].to_i
    @id = m[1].to_i
    @p = p0 - 1
    @s = 0
  end
  def score
    @s
  end
  def pos
    @p + 1
  end
  def id
    @id
  end
  def avance(c)
    @p = (@p + c)%10
    @s = @s + @p + 1
  end
  def wins?
    @s>=1000
  end
end

class DiracGame < BaseAOC
  DAY=21
  def initialize(data)
    @pp = data.lines.select{|l| l=~ /^Player/}.map{|l| Player.new(l)}
    @pp.each do |p|
      puts "Player #{p.id} starting position: #{p.pos}"
    end
  end

  def play1000
    d = DeterministicDice.new
    while !@pp.any?{|p| p.wins?}
      @pp.each do |p|
        a1 = d.roll
        a2 = d.roll
        a3 = d.roll
        a = a1 + a2 + a3
        p.avance(a)
        if p.wins?
          puts "Player #{p.id} rolls #{a1}+#{a2}+#{a3} and moves to space #{p.pos} for a final score of #{p.score}."
          break
        else
          puts "Player #{p.id} rolls #{a1}+#{a2}+#{a3} and moves to space #{p.pos} for a total score of #{p.score}."
        end
      end
    end
    looser = @pp.select{|p| !p.wins?}[0]
    puts "Looser score: #{looser.score}"
    puts "Total number of dice rols: #{d.nrols}"
    return looser.score * d.nrols
  end
end

class DiracGameTest < MiniTest::Test
  def test_play1000
    g = DiracGame.from_test_data
    s = g.play1000
    assert_equal 739785, s
  end
end

if MiniTest.run
  puts "Tests Passed!"

  g = DiracGame.from_data
  s = g.play1000
  puts "Looser's score * dice rols = #{s}"
end
