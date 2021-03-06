#!/usr/bin/env ruby

require 'minitest'
require 'minitest/rg'

require './aoc.rb'

class CrabAligner < BaseAOC
  DAY=7
  def initialize(data)
    @initial_positions = data.split(",").map{|sp| sp.to_i}
    @ncrabs = @initial_positions.count
  end
  # very stupid algorithm but data size is small...
  def align(cost_function="linear_cost")
    minx = @initial_positions.min
    maxx = @initial_positions.max
    minc = maxx * maxx * @ncrabs
    apos = nil
    minx.upto(maxx) do |x0|
      cost = @initial_positions.inject(0) {|c, x| c + self.send(cost_function, x, x0)}
      if cost < minc
        minc = cost 
        apos = x0
      end
    end
    puts "Crabs align at #{apos} (av pos = #{(maxx-minx)/2}) at cost of #{minc}"
    return minc
  end
  def linear_cost(x, x0)
    (x-x0).abs
  end
  def crab_cost(x, x0)
    d = (x-x0).abs
    d * (d+1) / 2
  end
end

class CrabAlignerTest < MiniTest::Test
  def test_align
    p = CrabAligner.from_test_data
    assert_equal 37, p.align
    assert_equal 168, p.align("crab_cost")
  end
end

if MiniTest.run
  puts "Tests Passed!"
  p = CrabAligner.from_data
  p.align
  p.align("crab_cost")
end

