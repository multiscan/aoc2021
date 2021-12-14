#!/usr/bin/env ruby
require 'minitest'
require 'minitest/rg'

require './aoc.rb'

# The rules are essentially a graph. Everytime one is applied
# a new char is created and a pair of chars is replaced by two pairs of chars
# the number of pairs is quite small and the rule applies the identically on
# all identical pairs: it is enough to count them. 
# For large number of steps it is not possible to store the full list of chars
# and, in fact, the quiz only ask for something related to number of chars.
class PolymerTemplate2 < BaseAOC
  DAY=14
  def initialize(data)
    ll = data.lines.map{|l| l.chomp}

    @rules = {}
    ll[2..].each do |l|
      f,t=l.split(" -> ")
      @rules[f] = t
    end
    p @rules

    # char counts
    @ccounts = {}

    # pairs counts
    @pcounts = {}

    template = ll[0]
    pairs(template).each do |p|
      pc = @pcounts[p] || 0
      @pcounts[p] = pc + 1
    end
    p @pcounts

    template.chars.each {|c| @ccounts[c] = (@ccounts[c]||0) + 1}
    p @ccounts
  end

  def run_once!
    pc = {}
    @pcounts.each do |k,v|
      pc[k] = v
    end
    @pcounts.each do |k,v|
      pc[k] = pc[k] - v
      t=@rules[k]
      a = "#{k[0]}#{t}"
      b = "#{t}#{k[1]}"
      pc[a] = (pc[a]||0) + v
      pc[b] = (pc[b]||0) + v
      @ccounts[t] = (@ccounts[t]||0) + v 
    end
    @pcounts = pc
  end

  def score()
    scc = @ccounts.values.sort
    scc.last - scc.first
  end

  def run!(n)
    n.times do
      run_once!
    end
  end

  def pairs(s)
    p = []
    0.upto(s.length-2) do |i| 
      p << "#{s[i]}#{s[i+1]}"
    end
    p
  end
end

class PolymerTemplate < BaseAOC
  DAY=14
  def initialize(data)
    ll = data.lines.map{|l| l.chomp}
    @template = ll[0]
    @rules = {}
    ll[2..].each do |l|
      f,t=l.split(" -> ")
      @rules[f] = "#{f[0]}#{t}"
    end
  end

  def run_once(s=@template)
    r = ""
    0.upto(s.length-2) do |i| 
      k = "#{s[i]}#{s[i+1]}"
      # puts "#{i} : #{k} -> #{@rules[k]}"
      r << @rules[k]
    end
    r << @template[-1]
    r
  end

  def run!(n=1)
    n.times do 
      @template = run_once
    end
    @template
  end

  def score(s=@template)
    c = s.chars.uniq.map{|c| s.count(c)}.sort
    c.last - c.first
  end

  def to_s
    r =  "template: #{@template}\n\n"
    @rules.each { |k,v| r << "#{k} -> #{v}\n" }
    r
  end
end

class PolymerTemplateTest < MiniTest::Test
  def test_polymer1
    dd = PolymerTemplate.from_test_data
    assert_equal "NCNBCHB", dd.run_once
    assert_equal "NCNBCHB", dd.run!(1)
    assert_equal "NBCCNBBBCBHCB", dd.run!(1)
    assert_equal "NBBBCNCCNBBNBNBBCHBHHBCHB", dd.run!(1)
    assert_equal "NBBNBNBBCCNBCNCCNBBNBBNBBBNBBNBBCBHCBHHNHCBBCBHCB", dd.run!(1)
    assert_equal 97, dd.run!(1).length
    assert_equal 3073, dd.run!(5).length
    assert_equal 1588, dd.score()
  end

  def test_polymer2
    d1 = PolymerTemplate.from_test_data
    d2 = PolymerTemplate2.from_test_data
    assert_equal d1.score, d2.score
    d1.run!(1)
    d2.run!(1)
    assert_equal d1.score, d2.score
    d1.run!(1)
    d2.run!(1)
    assert_equal d1.score, d2.score

    dd = PolymerTemplate2.from_test_data
    dd.run!(10)
    assert_equal 1588, dd.score

    dd.run!(30)
    assert_equal 2188189693529, dd.score    
    # assert_equal 1, 0
  end
end

if MiniTest.run
  puts "Tests Passed!"
  dd = PolymerTemplate.from_data
  dd.run!(10)
  puts "Score after 10 runs: #{dd.score}"

  dd = PolymerTemplate2.from_data
  dd.run!(40)
  puts "Score after 40 runs: #{dd.score}"

end
