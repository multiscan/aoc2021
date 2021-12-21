#!/usr/bin/env ruby

require 'minitest'
require 'minitest/rg'

require './aoc.rb'

class Sonar < BaseAOC
  DAY=1
  def initialize(data)
    @depths = data.split("\n").map{|v| v.to_i}
  end
  def count_increases(v=@depths)
    c = 0
    1.upto(v.count-1) do |i|
      c = c + 1 if v[i] > v[i-1]
    end
    return c
  end
  def count_sliding_increases(n=3)
    v = sliding_sum(n)
    count_increases(v)
  end

  def sliding_sum(n)
    v=@depths
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
end



class SonarTest < MiniTest::Test
  TA = "607 618 618 617 647 716 769 792".split(" ").map{|v| v.to_i}
  def test_count_increases
    s = Sonar.from_test_data
    assert_equal 7, s.count_increases
  end
  def test_sliding_sum
    s = Sonar.from_test_data
    assert_equal TA, s.sliding_sum(3)
  end
  def test_count_increases_on_sliding_sum
    s = Sonar.from_test_data
    assert_equal 5, s.count_sliding_increases(3)
  end
end


if MiniTest.run
  puts "Tests Passed!"
  s = Sonar.from_data
  puts s.count_increases
  puts s.count_sliding_increases
end