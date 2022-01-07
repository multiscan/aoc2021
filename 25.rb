#!/usr/bin/env ruby
require 'minitest'
require 'minitest/rg'

require './aoc.rb'

class Toro
  attr_reader :nr, :nc
  def initialize(n,m)
    @nr = n
    @nc = m
    reset
  end
  def reset
    @d = []
    @nr.times do
      @d << [0]*@nc
    end
  end
  def set_south(i,j)
    @d[i][j]=1
  end
  def set_east(i,j)
    @d[i][j]=2
  end
  def empty?(i,j)
    @d[i][j]==0
  end

  def each_south
    @d.each_with_index do |l,i|
      l.each_with_index do |c,j|
        yield i,j if c==1
      end
    end
  end

  def each_east
    @d.each_with_index do |l,i|
      l.each_with_index do |c,j|
        yield i,j if c==2
      end
    end
  end

  def each_south_with_move
    @d.each_with_index do |l,i|
      ii = (i + 1) % @nr
      l.each_with_index do |c,j|
        if c==1
          if @d[ii][j] == 0
            yield ii,j,1
          else
            yield i,j,0
          end
        end
      end
    end
  end

  def each_east_with_move
    @d.each_with_index do |l,i|
      l.each_with_index do |c,j|
        if c==2
          jj = (j + 1) % @nc
          if @d[i][jj] == 0
            yield i,jj,1
          else
            yield i,j,0
          end
        end
      end
    end
  end

  def to_s
    s=""
    @d.each do |l|
      l.each do |c|
        s << (c==0 ? "." : ( c==1 ? "v" : ">" ))
      end
      s << "\n"
    end
    s
  end
  def inspect
    s = "#{@nr} x #{@nc}\n"
    s << self.to_s
    s
  end
end

class CucumberMap < BaseAOC
  DAY=25
  def initialize(data)
    ll = data.lines.map{|l| l.chomp.chars}
    @t = Toro.new(ll.count, ll.first.count)
    ll.each_with_index do |l,i|
      l.each_with_index do |c,j|
        if c == "v"
          @t.set_south(i,j)
        elsif c==">"
          @t.set_east(i,j)
        end
      end
    end
  end

  def step
    t2 = Toro.new @t.nr, @t.nc
    nm=0
    @t.each_east_with_move do |i,j,m|
      nm += m
      t2.set_east(i,j)
    end
    @t.each_south do |i,j|
      t2.set_south(i,j)
    end
    @t.reset
    t2.each_south_with_move do |i,j,m|
      nm += m
      @t.set_south(i,j)
    end
    t2.each_east do |i,j|
      @t.set_east(i,j)
    end
    t2=nil
    return nm
  end

  def run
    ns = 1
    while self.step > 0
      ns += 1
    end
    ns
  end

  def to_s
    @t.to_s
  end
  def inspect
    @t.inspect
  end
end

class CucumberMoverTest < MiniTest::Test
  def test_init
    cm = CucumberMap.from_test_data("a")
    d = open("testdata/25a.d") { |f| f.read }
    assert_equal d, cm.to_s
  end

  def test_step
    cm = CucumberMap.new("...>>>>>...\n")
    nm = cm.step
    assert_equal "...>>>>.>..\n", cm.to_s
    assert_equal 1, nm
    nm=cm.step
    assert_equal "...>>>.>.>.\n", cm.to_s
    assert_equal 2, nm

    c0 = "..........\n.>v....v..\n.......>..\n..........\n"
    c1 = "..........\n.>........\n..v....v>.\n..........\n"
    cm=CucumberMap.new c0
    cm.step
    assert_equal c1, cm.to_s
  end

  def test_run
    cm = CucumberMap.from_test_data("a")
    ns = cm.run
    p cm
    assert_equal 58, ns
  end
end


if MiniTest.run
  puts "Tests Passed!"

  cm = CucumberMap.from_data
  ns = cm.run
  puts "Cucmbers stop moving after #{ns} steps"
end
