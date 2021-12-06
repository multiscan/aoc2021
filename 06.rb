#!/usr/bin/env ruby

require 'minitest'
require 'minitest/rg'

require './aoc.rb'

class LanternFishPopulation
  def initialize(s)
    @initial_state = s.split(",").map{|c| c.to_i}
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
  TD1="3,4,3,1,2"

  def test_initial_population
    p = LanternFishPopulation.new(TD1)
    assert_equal 5, p.count
  end
  def test_after_few_days
    p = LanternFishPopulation.new(TD1)
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
    p = LanternFishPopulation.new(TD1)
    18.times {p.step}
    assert_equal 26, p.count
  end
  def test_after_80_days
    p = LanternFishPopulation.new(TD1)
    80.times {p.step}
    assert_equal 5934, p.count
  end

end

if MiniTest.run
  puts "Tests Passed!"
  data = load_data(6)
  p = LanternFishPopulation.new(data)
  80.times{p.step}
  puts "After 80 days there are #{p.count} fish"

  p = LanternFishPopulation.new(data)
  256.times{p.step}
  puts "After 256 days there are #{p.count} fish"

end
