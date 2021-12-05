#!/usr/bin/env ruby

require 'minitest'
require 'minitest/rg'

require './aoc.rb'

class Point
  attr_reader :x, :y
  def initialize(s)
    @x, @y = s.split(",").map{|v| v.to_i}
  end
end

class Line
  def initialize(l)
    @f, @t = l.split(" -> ").map{|s| Point.new(s)}
  end
  def vh?
    @f.x == @t.x or @f.y == @t.y
  end
  def trace
    dx=@t.x - @f.x
    dy=@t.y - @f.y
    raise "unexpected point difference dx=#{dx} dy=#{dy}" unless dx.abs == dy.abs or dx == 0 or dy == 0
    ns=[dx.abs, dy.abs].max
    dx=dx/ns
    dy=dy/ns
    t = []
    rx = @f.x
    ry = @f.y
    (ns+1).times do
      t << "#{rx},#{ry}"
      rx = rx + dx
      ry = ry + dy
    end
    # puts "f: #{@f.x},#{@f.y}   t: #{@t.x},#{@t.y}"
    # puts "t: #{t.join('  ')}"
    return t
  end
end

class Vents
  def initialize(data, vhonly=false)
    @lines = data.lines.map { |l| Line.new(l) }
    if vhonly
      @lines.select!{|l| l.vh? }
    end
    compute_crossings()
  end
  def line(i)
    @lines[i]
  end
  def count
    @lines.count 
  end
  def compute_crossings
    @crossings={}
    @lines.each do |l|
      l.trace.each do |k|
        @crossings[k] = (@crossings[k] || 0) + 1
      end
    end
  end
  def count_dangerous_spots
    @crossings.values.count {|c| c > 1}
  end
end


class VentsTest < MiniTest::Test
  TD1="""0,9 -> 5,9
    8,0 -> 0,8
    9,4 -> 3,4
    2,2 -> 2,1
    7,0 -> 7,4
    6,4 -> 2,0
    0,9 -> 2,9
    3,4 -> 1,4
    0,0 -> 8,8
    5,5 -> 8,2
"""

  def test_play
    b = Vents.new(TD1, true)
    assert_equal 6, b.count
    assert_equal ["0,9", "1,9", "2,9", "3,9", "4,9", "5,9"], b.line(0).trace
    assert_equal ["9,4", "8,4", "7,4", "6,4", "5,4", "4,4", "3,4"], b.line(1).trace
    assert_equal 5, b.count_dangerous_spots

    b = Vents.new(TD1, false)
    assert_equal 10, b.count
    assert_equal 12, b.count_dangerous_spots
  end

end

if MiniTest.run
  puts "Tests Passed!"
  data = load_data(5)
  v = Vents.new(data, true)
  ds = v.count_dangerous_spots
  puts "Number of points where hv vents cross at least once: #{ds}"

  v = Vents.new(data, false)
  ds = v.count_dangerous_spots
  puts "Number of points where any kind of vents cross at least once: #{ds}"
end
