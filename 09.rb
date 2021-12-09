#!/usr/bin/env ruby

require 'minitest'
require 'minitest/rg'

require './aoc.rb'

class Mat
  attr_reader :ni, :nj, :d
  def initialize(data)
    if data.class == String
      ll = data.lines.map {|l| l.chomp.chars.map{|v| v.to_i}}
      @ni = ll.count
      @nj = ll.first.count
      @d = ll.flatten
    elsif data.class == Mat
      @ni = data.ni
      @nj = data.nj
      @d = data.d.dup
    else
      raise "Unexpected new data for Mat"
    end
  end
  def get(i,j)
    return 10 if (i<0 || i>=@ni || j<0 || j>=@nj)
    return @d[i*@nj+j]
  end
  def set(i,j,v)
    unless i<0 || i>=@ni || j<0 || j>=@nj
      @d[i*@nj+j]=11
    end
  end
  def inspect
    s = "-- #{@ni} x #{@nj}\n"
    @d.each_slice(@nj) do |l|
      s << l.map{|v| sprintf("%2d", v)}.join(" ") << "\n"
    end
    s
  end

  def local_minima
    @local_minima ||= locate_local_minima
  end

  private

  def locate_local_minima
    r = []
    0.upto(@ni) do |i|
      0.upto(@nj) do |j|
        m = get(i,j)
        unless ( (m>=get(i+1,j)) or (m>=get(i-1,j)) or (m>=get(i,j+1)) or (m>=get(i,j-1)) )
          # puts "local minima in #{i},#{j} :  #{m}"
          r << [i,j]
        end
      end
    end
    r
  end
end

class HMap < BaseAOC
  DAY=9
  def initialize(data)
    @d = Mat.new(data)
    @locmin = nil
  end

  def basin_size(ii,jj)
    b = Mat.new(@d)
    c = 0
    p0 = [[ii,jj]]
    while !p0.empty?
      c = c + p0.count
      p1 = []
      p0.each do |i,j|
        b.set(i,j,11)
        p1 << [i+1, j] if b.get(i+1, j)<9
        p1 << [i-1, j] if b.get(i-1, j)<9
        p1 << [i, j+1] if b.get(i, j+1)<9
        p1 << [i, j-1] if b.get(i, j-1)<9
      end
      p0 = p1.uniq
    end
    # puts b.inspect
    return c
  end

  def sum_low_points_risk_levels
    @d.local_minima.inject(0) { |s, o| i,j=o; s + @d.get(i,j) + 1 }
  end

  def largest_basin_size_product
    @d.local_minima.map {|i,j| basin_size(i,j)}.sort.last(3).reduce(1, :*)
  end
end

class HMapTest < MiniTest::Test
  def test_align
    dd = HMap.from_test_data
    assert_equal 15, dd.sum_low_points_risk_levels
    assert_equal  3, dd.basin_size(0,0)
    assert_equal  9, dd.basin_size(0,9)
    assert_equal 14, dd.basin_size(2,3)
    assert_equal  9, dd.basin_size(4,8)
    assert_equal 1134, dd.largest_basin_size_product
  end
end

if MiniTest.run
  puts "Tests Passed!"
  dd = HMap.from_data
  puts "sum of low points risk levels: #{dd.sum_low_points_risk_levels}"
  puts "product of three largest basins: #{dd.largest_basin_size_product}"
end
