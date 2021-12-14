#!/usr/bin/env ruby

require 'minitest'
require 'minitest/rg'

require './aoc.rb'


class Octopus
  attr_reader :e
  def initialize(initial_energy)
    @id = ObjectSpace.each_object(self.class).count
    @e = initial_energy
    @nn = []
    @flash = false
  end
  def setnn(v)
    @nn = v
  end
  def step
    @already_flashed = false
    @e = @e + 1
  end
  def update
    @nn.each {|o| @e = @e + 1 if o.flash?}
  end
  def update_flash
    @flash = (not @already_flashed) && (@e > 9)
    @already_flashed = true if @flash
    @flash
  end
  def flash?
    @flash
  end
  def to_s
    "#{@id}: #{@e}   #{@flash ? 'f' : ''}"
  end
  def step_done
    @e = 0 if @e > 9
  end
end

class Cavern < BaseAOC
  DAY=11
  attr_reader :flashes
  def initialize(data)
    ll = data.lines.map {|l| l.chomp.chars.map{|v| Octopus.new(v.to_i)}}
    @ni = ll.count
    @nj = ll.first.count
    ll.each_with_index do |l, ii|
      l.each_with_index do |o, jj|
        nn=[]
        ([0,ii-1].max).upto([@ni-1, ii+1].min) do |i|
          ([0,jj-1].max).upto([@nj-1, jj+1].min) do |j|
            nn << ll[i][j] unless (i==ii && j==jj)
          end
        end
        o.setnn(nn)
      end
    end
    @octos = ll.flatten
    @flashes = 0
  end
  def step
    @octos.each{|o| o.step}

    anyflash = false
    @octos.each{|o| @flashes = @flashes + 1 if o.update_flash}

    while @octos.any?{|o| o.flash?}
      @octos.each{|o| o.update}

      @octos.each{|o| @flashes = @flashes + 1 if o.update_flash}
    end
    @octos.each{|o| o.step_done}

  end
  def all_flashed?
    @octos.all?{|o| o.e == 0}
  end

  # run until all octopus flash
  def run
    nsteps = 0
    while !self.all_flashed?
      step
      nsteps = nsteps + 1
    end
    nsteps
  end
  def to_s
    s=""
    @octos.each_slice(@nj).to_a.each do |l|
      s << l.map{|o| o.e.to_s }.join('') << "\n"
    end
    s
  end
end

class CavernTest < MiniTest::Test
  TD1="""\
11111
19991
19191
19991
11111
"""
  TD2="""\
34543
40004
50005
40004
34543
"""
  TD3="""\
45654
51115
61116
51115
45654
"""
  TD4="""\
6594254334
3856965822
6375667284
7252447257
7468496589
5278635756
3287952832
7993992245
5957959665
6394862637
"""
  TD5="""\
8807476555
5089087054
8597889608
8485769600
8700908800
6600088989
6800005943
0000007456
9000000876
8700006848
"""

  def test_corruption

    dd = Cavern.new(TD1)
    dd.step
    assert_equal(TD2, dd.to_s)
    dd.step
    assert_equal(TD3, dd.to_s)
    dd = Cavern.from_test_data
    dd.step
    assert_equal(TD4, dd.to_s)
    dd.step
    assert_equal(TD5, dd.to_s)

    dd = Cavern.from_test_data
    10.times {dd.step}
    assert_equal 204, dd.flashes

    dd = Cavern.from_test_data
    100.times {dd.step}
    assert_equal 1656, dd.flashes

    dd = Cavern.from_test_data
    ns = dd.run
    assert_equal 195, ns

  end
end

if MiniTest.run
  puts "Tests Passed!"
  dd = Cavern.from_data
  100.times {dd.step}
  puts "Number of Flashes after 100 steps: #{dd.flashes}"

  dd = Cavern.from_data
  ns = dd.run
  puts "All octopus flash after #{ns} steps"
end
