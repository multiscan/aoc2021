#!/usr/bin/env ruby

require 'minitest'
require 'minitest/rg'

require './aoc.rb'

# https://github.com/rails/rails/blob/7-0-stable/activesupport/lib/active_support/core_ext/array/extract.rb
class Array
  # Removes and returns the elements for which the block returns a true value.
  # If no block is given, an Enumerator is returned instead.
  #
  #   numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  #   odd_numbers = numbers.extract! { |number| number.odd? } # => [1, 3, 5, 7, 9]
  #   numbers # => [0, 2, 4, 6, 8]
  def extract!
    return to_enum(:extract!) { size } unless block_given?

    extracted_elements = []

    reject! do |element|
      extracted_elements << element if yield(element)
    end

    extracted_elements
  end
end


class SignalData
  def initialize(line)
    pp, oo = line.split("|")
    @patts = pp.split(" ").map{|p| p.chars.sort}
    @dispo = oo.split(" ").map{|o| o.chars.sort.join('')}
    @code=nil
  end

  def count_easy_digits
    @dispo.count {|d| [2,3,4,7].include?(d.length)}
  end

  # for sure there is a more elegant way of doing this!
  def decode
    return unless @code.nil?
    @w = {
      'a' => nil,
      'b' => nil,
      'c' => nil,
      'd' => nil,
      'e' => nil,
      'f' => nil,
      'g' => nil,      
    }
    pp = @patts.dup
    c = {
      0 => nil,
      1 => pp.extract!{|p| p.count == 2}.first,
      2 => nil,
      3 => nil,
      4 => pp.extract!{|p| p.count == 4}.first,
      5 => nil,
      6 => nil,
      7 => pp.extract!{|p| p.count == 3}.first,
      8 => pp.extract!{|p| p.count == 7}.first,
      9 => nil
    }
    c[9] = pp.extract!{|p| p.count == 6 && ( (p & c[4]) == c[4] )  }.first
    c[0] = pp.extract!{|p| p.count == 6 && ( (p + c[4]).uniq.count == 7 ) && ((p + c[7]).uniq.count < 7) }.first
    c[6] = pp.extract!{|p| p.count == 6 && p != c[0] && p != c[9]}.first
    @w['a'] = (c[7]-c[1]).first
    @w['c'] = (c[8]-c[6]).first
    @w['d'] = (c[8]-c[0]).first
    @w['e'] = (c[8]-c[9]).first
    @w['g'] = (c[8]-c[4]-[@w['a'],@w['e']]).first
    c[5] = pp.extract!{|p| p == c[6] - [@w['e']]}.first
    c[2] = pp.extract!{|p| p.include?(@w['e'])}.first
    c[3] = pp.first
    @w['b'] = (c[9]-c[3]).first
    @w['f'] = (c[8]-c[2]-[@w['b']]).first

    @code = {}
    c.each{|i, v| @code[v.join('')]=i}
  end

  def read
    decode
    @dispo.map{|c| @code[c]}.join('').to_i
  end
end

class DisplayDecoder < BaseAOC
  DAY=8
  def initialize(data)
    @sd = data.lines.map {|l| SignalData.new(l)}
  end

  def count_easy_digits
    @sd.sum{|d| d.count_easy_digits}
  end

  def sum_read
    @sd.sum{|d| d.read}
  end
end

class DisplayDecoderTest < MiniTest::Test
  def test_align
    dd = DisplayDecoder.from_test_data
    assert_equal 26, dd.count_easy_digits
    sd = SignalData.new("acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf")
    assert_equal 5353, sd.read
    assert_equal 61229, dd.sum_read
  end
end

if MiniTest.run
  puts "Tests Passed!"
  dd = DisplayDecoder.from_data
  puts "Number of easy digits: #{dd.count_easy_digits}"
  puts "Sum of all decoded readings: #{dd.sum_read}"

end



