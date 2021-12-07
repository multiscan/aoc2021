#!/usr/bin/env ruby

require 'minitest'
require 'minitest/rg'

require './aoc.rb'

class Submarine < BaseAOC
  attr_reader :gamma, :epsilon, :power
  DAY=3
  def initialize(data)
    @diag = data.lines().map{|l| l.strip }.map{|s| s.split('').map{|v| v.to_i}}
    nbits = @diag.first.count
    nwords = @diag.count
    nhw = nwords/2
    count1 = @diag.inject(Array.new(nbits, 0)) do |s, v|
      s.map.with_index{|ss, i| ss+v[i]}
    end
    puts "nbits: #{nbits}  nwords: #{nwords}    nhw: #{nhw}   count1: #{count1.join(',')}"
    raise "Undecidable situation" if nhw*2==nwords && count1.include?(nhw)
    @gamma=count1.map{|c| c>nhw ? 1 : 0}.join("").to_i(2)
    @epsilon=(~@gamma)&(2**nbits-1)
    @power = @gamma*@epsilon
  end

  def count_ones_at(ib, vv) 
    vv.map{|v| v[ib]}.select{|v| v==1 }.count
  end

  # in most_common when equal we take 1
  def most_common_bit(ib, vv)
    n1 = count_ones_at(ib,vv)
    2*n1 >= vv.count ? 1 : 0
  end

  # in least_common when equal we take 0
  def least_common_bit(ib, vv)
    n1 = count_ones_at(ib,vv)
    2*n1 < vv.count ? 1 : 0
  end

  def select_with_bit(i, b, vv)
    vs = vv.select{ |v| v[i] == b }
    return vs
  end

  def oxygen_generator_rating
    i=0
    b = most_common_bit(i,@diag)
    v = select_with_bit(i, b, @diag)
    while v.count > 1
      i = i + 1
      b = most_common_bit(i,v)
      v = select_with_bit(i, b, v)
    end
    v.first.join("").to_i(2)
  end

  def co2_scrubber_rating
    i=0
    b = least_common_bit(i,@diag)
    v = select_with_bit(i, b, @diag)
    while v.count > 1
      i = i + 1
      b = least_common_bit(i,v)
      v = select_with_bit(i, b, v)
    end
    v.first.join("").to_i(2)
  end

end

class SubmarineTest < MiniTest::Test
  def test_diagnostics
    s = Submarine.from_test_data
    assert_equal 22, s.gamma
    assert_equal 9, s.epsilon
    assert_equal 198, s.power

    assert_equal 23, s.oxygen_generator_rating
    assert_equal 10, s.co2_scrubber_rating
  end
end


if MiniTest.run
  puts "Tests Passed!"

  s = Submarine.from_data
  puts "power: #{s.power}"

  ogr = s.oxygen_generator_rating
  csr = s.co2_scrubber_rating
  puts "oxygen generator rating: #{ogr}"
  puts "CO2 scrubber rating: #{csr}"
  puts "product: #{ogr*csr}"
end