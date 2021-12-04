#!/usr/bin/env ruby

require 'minitest'
require 'minitest/rg'

require './aoc.rb'

class Submarine
  attr_reader :gamma, :epsilon, :power
  def initialize()
    @d = 0
    @x = 0
  end

  def play(v)
    v.each {|s| move(s)}
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
  def initialize()
    @aim = 0
    super
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
  TI = [
    "forward 5",
    "down 5",
    "forward 8",
    "up 3",
    "down 8",
    "forward 2",
  ]

  def test_play
    s = Submarine.new()
    assert_equal 150, s.play(TI)

    s = Submarine2.new()
    assert_equal 900, s.play(TI)
  end

end


if MiniTest.run                                # The Run/Kill Switch
  puts "Tests Passed!"

  data = load_data(2).lines()
  s = Submarine.new
  r1 = s.play(data)
  puts "r1 = #{r1}"

  s = Submarine2.new
  r2 = s.play(data)
  puts "r2 = #{r2}"
end