#!/usr/bin/env ruby
require 'minitest'
require 'minitest/rg'

require './aoc.rb'

class TrajectoryComputer < BaseAOC
  DAY=17

  def initialize(data)
    # target area: x=155..215, y=-132..-72
    m = /target area: x=([0-9]+)\.\.([0-9]+), y=(-?[0-9]+)\.\.(-?[0-9]+)/.match(data)
    @target_xmin,@target_xmax,@target_ymin,@target_ymax=m[1..4].map{|s| s.to_i}
    puts "target #{@target_xmin} < x < #{@target_xmax} / #{@target_ymin} < y < #{@target_ymax}"
  end

  def maxh
    all_possible_hits.map{|a| a[1]}.select{|vy| vy > 0}.map{|vy| vy*(vy+1)/2}.max
  end

  def count_hits
    all_possible_hits.count
  end

  def hit_target?(vx, vy)
    h = all_possible_hits.select{|a| a[0]==vx && a[1]==vy}
    !h.empty?
  end

  def all_possible_hits
    @all_possible_hits ||= begin
      pvx = possible_nvx
      pvy = possible_nvy
      pvxvy = []
      pvx.each do |n, vx|
        if n == vx
          pvy.select{|m,vy| m>=n}.each {|m,vy| pvxvy << [vx, vy]}
        else
          pvy.select{|m,vy| m==n}.each {|m,vy| pvxvy << [vx, vy]}
        end
      end
      pvxvy.uniq
    end
  end

  # given the horizontal distance, list all possible vx that can exactly 
  # reach that distance: if n is the number of steps n in [1, d)
  # x + (x-1) + (x-2) + ... (x-n+1) = d 
  # nx = d + (1+2+3+...+n-1) = d + (n-1) * n / 2 
  # x = d / n + (n-1)/2
  # since x >= 0 we keep only x >= n
  # due to integer arithmetics we have to test x and x+1
  # output is sorted by n steps 
  def possible_nvx(dmin=@target_xmin, dmax=@target_xmax)
    vv = []
    dmin.upto(dmax) do |d|
      d.times do |i|
        n = i + 1
        x1 = d / n + (n-1)/2
        x2 = x1 + 1
        # puts "n:#{n}  x=#{x1},#{x2}   #{n*x1 - (n-1)*n/2}  #{n*x2 - (n-1)*n/2}"
        next if x2 < n
        vv << [n,x1] if n*x1 == d + (n-1)*n/2
        vv << [n,x2] if n*x2 == d + (n-1)*n/2
      end
    end
    vv.uniq.sort{|a,b| a[0] <=> b[0]}
  end

  def possible_nvy(dmin=@target_ymin, dmax=@target_ymax)
    vv = []
    mx = Integer.sqrt(-dmin)
    dmin.upto(dmax) do |d|
      # take only negative vy, positive ones are the same just vy*2-1 steps later
      1.upto(-d) do |m|
        d.upto(0) do |vy|
          if m*vy == d + m*(m-1)/2
            vv << [m, vy]
            vv << [m-vy*2-1, -vy-1] if vy < -1
          end
        end
      end

    end
    vv.sort{|a,b| a[0] <=> b[0]}
  end

  # given the number of steps n find possible vertical speed vy (x) for which 
  # x + (x-1) + (x-2) + ... + (x-n+1) stays in between target. Same as for x
  # for d in @target_ymin .. @target_ymax
  # x + (x-1) + (x-2) + ... + (x-n+1) = d
  # n*x = d + (n-1) * n / 2
  # x = d/n + (n-1) / 2       but this time any n is good
  def possible_vy(n, dmin=@target_ymin, dmax=@target_ymax)
    vv = []
    dmin.upto(dmax) do |d|
      x = d / n + (n-1)/2
      if n*x == d + (n-1)*n/2
        vv << x
      else
        x = x + 1
        vv << x if n*x == d + (n-1)*n/2
      end
    end
    vv.sort
  end

end

class TrajectoryComputerTest < MiniTest::Test
  def test_tc
    tc = TrajectoryComputer.new("target area: x=20..30, y=-10..-5")
    assert_equal [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], tc.possible_nvx.map{|a| a[1]}.uniq.sort
p tc.all_possible_hits    
puts "aph.count = #{tc.all_possible_hits.count}"
    assert_equal true, tc.hit_target?(7,2)
    assert_equal true, tc.hit_target?(6,3)
    assert_equal true, tc.hit_target?(9,0)
    assert_equal false, tc.hit_target?(17,-4)
    assert_equal true, tc.hit_target?(6,9)
    assert_equal 45, tc.maxh
    assert_equal 112, tc.count_hits

    # assert_equal 1, 0
  end 
end


if MiniTest.run
  puts "Tests Passed!"

  tc = TrajectoryComputer.from_data
  h, vx, vy = tc.maxh
  puts "Max h=#{h} for v=(#{vx}, #{vy})"
  c = tc.count_hits
  puts "Total number of hits: #{c}"
end
