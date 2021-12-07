#!/usr/bin/env ruby

require 'minitest'
require 'minitest/rg'

require './aoc.rb'

class Submarine < BaseAOC
  DAY = 2
  attr_reader :gamma, :epsilon, :power
  def initialize(data)
    @moves = data.lines()
    @d = 0
    @x = 0
  end

  def play()
    @moves.each {|s| move(s)}
    # returns the final position/depth multiplied
    @d * @x
  end
  def move(s)
    c, a = s.split
    self.send(c, a.to_i)
  end
  def up(a)
    @d = @d - a
  end
  def down(a)
    @d = @d + a
  end
  def forward(a)
    @x = @x + a
  end
end

class Submarine2 < Submarine
  def initialize(data)
    @aim = 0
    super(data)
  end
  def up(a)
    @aim = @aim - a
  end
  def down(a)
    @aim = @aim + a
  end
  def forward(a)
    @x = @x + a
    @d = @d + @aim * a
  end
end

class SubmarineTest < MiniTest::Test
  def test_play
    s = Submarine.from_test_data
    assert_equal 150, s.play

    s = Submarine2.from_test_data
    assert_equal 900, s.play
  end

end


if MiniTest.run
  puts "Tests Passed!"

  s = Submarine.from_data
  r1 = s.play
  puts "r1 = #{r1}"

  s = Submarine2.from_data
  r2 = s.play
  puts "r2 = #{r2}"
end