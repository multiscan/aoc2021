#!/usr/bin/env ruby

require 'minitest'
require 'minitest/rg'

require './aoc.rb'

class LanternFishPopulation < BaseAOC
  DAY=6
  def initialize(data)
    @initial_state = data.split(",").map{|c| c.to_i}
    reset()
  end
  def reset
    @istep = 0
    @state = [0]*9
    p @state
    @initial_state.each do |i|
      @state[i] = @state[i] + 1
    end
  end
  def step
    @istep = @istep + 1
    e=@state[0]
    0.upto(7) do |i|
      @state[i] = @state[i+1]
    end
    @state[8] = e
    @state[6] = @state[6] + e
    # puts "After #{@istep} days: #{self.count} lantern fish - #{@state.join(",")}"
  end
  def count
    @state.sum
  end
end

class LanternFishPopulationTest < MiniTest::Test
  def test_initial_population
    p = LanternFishPopulation.from_test_data
    assert_equal 5, p.count
  end
  def test_after_few_days
    p = LanternFishPopulation.from_test_data
    p.step
    assert_equal 5, p.count
    p.step
    assert_equal 6, p.count
    p.step
    assert_equal 7, p.count
    p.step
    assert_equal 9, p.count
  end
  def test_after_18_days
    p = LanternFishPopulation.from_test_data
    18.times {p.step}
    assert_equal 26, p.count
  end
  def test_after_80_days
    p = LanternFishPopulation.from_test_data
    80.times {p.step}
    assert_equal 5934, p.count
  end

end

if MiniTest.run
  puts "Tests Passed!"
  p = LanternFishPopulation.from_data
  80.times{p.step}
  puts "After 80 days there are #{p.count} fish"

  p = LanternFishPopulation.from_data
  256.times{p.step}
  puts "After 256 days there are #{p.count} fish"

end
