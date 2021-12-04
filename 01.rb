#!/usr/bin/env ruby

require 'minitest'
require 'minitest/rg'

require './aoc.rb'

class Sonar
  def initialize(l)
    @depths = l
  end
  def count_increases()
    c = 0
    1.upto(@depths.count-1) do |i|
      c = c + 1 if @depths[i] > @depths[i-1]
    end
    return c
  end
end

def sliding_sum(v, n)
  a=0
  b=n-1
  s=v[a..b].sum
  sv=[s]
  b=b+1
  while(b<v.count)
    s = s - v[a]
    a = a + 1
    s = s + v[b]
    sv << s
    b = b + 1
  end
  sv
end


class SonarTest < MiniTest::Test
  TV = "199 200 208 210 200 207 240 269 260 263".split(" ").map{|v| v.to_i}
  TA = "607 618 618 617 647 716 769 792".split(" ").map{|v| v.to_i}
  def test_count_increases
    s = Sonar.new(TV)
    assert_equal 7, s.count_increases
  end
  def test_sliding_sum
    assert_equal TA, sliding_sum(TV, 3)
  end
  def test_count_increases_on_sliding_sum
    s = Sonar.new(sliding_sum(TV, 3))
    assert_equal 5, s.count_increases
  end
end


if MiniTest.run                                # The Run/Kill Switch
  puts "Tests Passed!"

  data = load_data(1).split("\n").map{|v| v.to_i}
  s = Sonar.new(data)
  puts s.count_increases
  s = Sonar.new(sliding_sum(data, 3))
  puts s.count_increases
end