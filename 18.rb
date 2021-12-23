#!/usr/bin/env ruby
require 'minitest'
require 'minitest/rg'

require './aoc.rb'

class SnailfishNumber
  attr_accessor :left,:right,:parent
  attr_reader :value
  def initialize()
    @left = nil
    @right = nil
    @value = nil
    @parent = nil
  end
  def self.from_string(s)
    n = SnailfishNumber.new()
    if s =~ /^[0-9]+$/
      n.value = s.to_i
    else
      n.load_string(s)
    end
    n
  end
  def regular?
    not @value.nil?
  end
  def load_string(s)
    ss = s[1..-2]
    ls=""
    rs=""
    l = 0
    cc = ""
    ss.chars.each do |c|
      if l==0 && c==","
        @left = SnailfishNumber.from_string(cc)
        @left.parent = self
        cc = ""
        next
      end
      cc << c
      l = l + 1 if c == "["
      l = l - 1 if c == "]"
    end
    @right = SnailfishNumber.from_string(cc)
    @right.parent = self
  end
  def value=(v)
    @value = v
    unless v.nil?
      @left = nil
      @right = nil
    end
  end

  def +(other)
    r = SnailfishNumber.new
    if self.regular? && other.regular?
      r.value=(self.value + other.value)
    else
      r.left = self
      r.right = other
      self.parent = r
      other.parent = r
    end
    r.reduce
    r
  end

  def duplicate_sum(other)
    r = SnailfishNumber.new
    if self.regular? && other.regular?
      r.value=(self.value + other.value)
    else
      r.left = SnailfishNumber.from_string(self.inspect)
      r.right = SnailfishNumber.from_string(other.inspect)
      r.left.parent = r
      r.right.parent = r
    end
    r.reduce
    r
  end

  def maxdept(l=0)
    return l if regular?
    [l, @left.maxdept(l+1), @right.maxdept(l+1)].max
  end

  def magnitudo
    if regular?
      return @value
    else
      return 3 * @left.magnitudo + 2 * @right.magnitudo
    end
  end

  def reduce_once_for_test
    if explode
      return "exploded:#{inspect}"
    elsif split
      return "splitted:#{inspect}"
    else
      return "Result: #{inspect}"
    end
  end

  def reduce
    one = true
    while one
      one = explode
      unless one
        one = split
      end
    end
  end

  def explode
    return false if regular?
    c = self.find_explode_candidate
    return false if c.nil?
    raise "unexpected explode candidate that does not contain only regular numbers" unless c.left.regular? && c.right.regular?
    rr = c.regular_on_the_right
    rr.value = (rr.value + c.right.value) if rr
    rl = c.regular_on_the_left
    rl.value = (rl.value + c.left.value) if rl
    c.value=0
    return true
  end

  def split
    c = find_split_candidate
    return false if c.nil?
    l = c.value / 2
    r = c.value - l
    ln = SnailfishNumber.new ; ln.value=l ; ln.parent = c
    rn = SnailfishNumber.new ; rn.value=r ; rn.parent = c
    c.value=nil
    c.left=ln
    c.right=rn
    return true
  end

  def find_explode_candidate(l=0)
    return nil if regular?
    return self if l==4
    c = @left.find_explode_candidate(l+1)
    return c unless c.nil?
    c = @right.find_explode_candidate(l+1)
    return c
  end

  def find_split_candidate
    if regular?
      return @value>9 ? self : nil
    else
      l = @left.find_split_candidate
      return l unless l.nil?
      return @right.find_split_candidate
    end
  end

  # go up until we can go right, then go down as left as possible
  def regular_on_the_right
    c = self
    p = c.parent
    r = nil
    while p
      r = p.right
      # puts "loop: c=#{c.inspect}   p=#{p.inspect}    r=#{r.inspect}    c==r: #{c==r}"
      break if r && r != c
      c = p
      p = c.parent
    end
    # puts "after loop: c=#{c.inspect}   p=#{p.inspect}    r=#{r.inspect}"
    return nil unless p
    return r if r.regular?
    p = r
    # puts "down: p=#{p.inspect}"
    while p
      p = p.left
      # puts "loop: p=#{p}"
      return p if p && p.regular?
    end
    return nil
  end

  # go up until we can go right, then go down as left as possible
  def regular_on_the_left
    c = self
    p = c.parent
    r = nil
    while p
      r = p.left
      # puts "loop: c=#{c.inspect}   p=#{p.inspect}    r=#{r.inspect}    c==r: #{c==r}"
      break if r && r != c
      c = p
      p = c.parent
    end
    # puts "after loop: c=#{c.inspect}   p=#{p.inspect}    r=#{r.inspect}"
    return nil unless p
    return r if r.regular?
    p = r
    # puts "down: p=#{p.inspect}"
    while p
      p = p.right
      # puts "loop: p=#{p}"
      return p if p && p.regular?
    end
    return nil
  end

  def inspect
    regular? ? @value.to_s : "[#{@left.inspect},#{@right.inspect}]"
  end

  def debug
    regular? ? "(#{@value}|#{@left.nil? && @right.nil?},#{@parent.nil?})" : "[#{@left.debug},#{@right.debug}|#{@value.nil?},#{@parent.nil?}]"
  end
end

class SnailfishHomework < BaseAOC
  DAY=18

  def initialize(data)
    @nn = data.lines.map{|l| SnailfishNumber.from_string(l.chomp)}
  end

  def sum_all
    # @nn.sum
    n = @nn.first
    1.upto(@nn.count-1) do |m|
      n = n + @nn[m]
    end
    n
  end

  def largest_pair_magnitude
    mx = 0
    1.upto(@nn.count-1) do |i|
      a = @nn[i]
      0.upto(i-1) do |j|
        b = @nn[j]
        # sum operation is destructive on operators
        # therefore we need another sum that make a copy before
        s1 = a.duplicate_sum(b) ; s1m = s1.magnitudo
        s2 = b.duplicate_sum(a) ; s2m = s2.magnitudo
        mx = [mx, s1m, s2m].max
      end
    end
    mx
  end
end

class SnailfishNumberTest < MiniTest::Test
  def test_init
    [
      "[1,2]",
      "[[1,2],3]",
      "[9,[8,7]]",
      "[[1,9],[8,5]]",
      "[[[[1,2],[3,4]],[[5,6],[7,8]]],9]",
      "[[[9,[3,8]],[[0,9],6]],[[[3,7],[4,9]],3]]",
      "[[[[1,3],[5,3]],[[1,3],[8,7]]],[[[4,9],[6,9]],[[8,2],[7,3]]]]",
    ].each do |s|
      assert_equal s, SnailfishNumber.from_string(s).inspect
    end
  end

  def test_basic_sum
    a = SnailfishNumber.from_string("[1,2]")
    b = SnailfishNumber.from_string("[[3,4],5]")
    c = a + b
    assert_equal "[[1,2],[[3,4],5]]", c.inspect
  end
  def test_maxdepth
    assert_equal 1, SnailfishNumber.from_string("[1,2]").maxdept
    assert_equal 2, SnailfishNumber.from_string("[[1,2],3]").maxdept
    assert_equal 4, SnailfishNumber.from_string("[[[[1,3],[5,3]],[[1,3],[8,7]]],[[[4,9],[6,9]],[[8,2],[7,3]]]]").maxdept
    assert_equal 5, SnailfishNumber.from_string("[[[[[9,8],1],2],3],4]").maxdept
  end
  def test_explode_candidate
    [
      "[[[1,2],3],4]", "nil",
      "[[[[[9,8],1],2],3],4]", "[9,8]",
      "[7,[6,[5,[4,[3,2]]]]]", "[3,2]",
      "[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]", "[7,3]",
      "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]", "[3,2]",
      "[[[[8,7],[7,0]],[[7,8],[[7,7],15]]],[[[0,4],6],[8,7]]]", "[7,7]",
    ].each_slice(2) do |s|
      f,t = s
      n = SnailfishNumber.from_string(f)
      assert_equal t, n.find_explode_candidate.inspect
    end
  end
  def test_regular_on_lr
    n = SnailfishNumber.from_string("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]")
    d = n.left.right.right.right
    r = d.regular_on_the_right
    assert_equal "6", r.inspect

    n = SnailfishNumber.from_string("[[9,8],1]")
    d = n.left
    r = d.regular_on_the_right
    assert_equal "1", r.inspect

    n = SnailfishNumber.from_string("[7,[6,[5,[4,[3,2]]]]]")
    d = n.right.right.right.right
    r = d.regular_on_the_left
    assert_equal "4", r.inspect
  end
  def test_explode
    [
      "[[[[[9,8],1],2],3],4]", "[[[[0,9],2],3],4]",
      "[7,[6,[5,[4,[3,2]]]]]", "[7,[6,[5,[7,0]]]]",
      "[[6,[5,[4,[3,2]]]],1]", "[[6,[5,[7,0]]],3]",
      "[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]", "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]",
      "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]", "[[3,[2,[8,0]]],[9,[5,[7,0]]]]",
      "[[[[8,7],[7,0]],[[7,8],[[7,7],15]]],[[[0,4],6],[8,7]]]", "[[[[8,7],[7,0]],[[7,15],[0,22]]],[[[0,4],6],[8,7]]]",
    ].each_slice(2) do |s|
      f,t=s
      n = SnailfishNumber.from_string(f)
      n.explode
      assert_equal t, n.inspect
    end
  end
  def test_split_candidate
    [
      "[[[[0,7],4],[15,[0,13]]],[1,1]]", "15",
      "[[[[0,7],4],[[7,8],[0,13]]],[1,1]]", "13",
      "[[1,10],11]", "10",
      "[[1,2],[[3,11],12]]", "11"
    ].each_slice(2) do |s|
      f,t = s
      n = SnailfishNumber.from_string(f)
      assert_equal t, n.find_split_candidate.inspect
    end
  end
  def test_split
    [
      "[[[[0,7],4],[15,[0,13]]],[1,1]]", "[[[[0,7],4],[[7,8],[0,13]]],[1,1]]",
      "[[[[0,7],4],[[7,8],[0,13]]],[1,1]]", "[[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]",
    ].each_slice(2) do |s|
      f,t = s
      n = SnailfishNumber.from_string(f)
      n.split
      assert_equal t, n.inspect
    end
  end
  def test_reduce
    [
      "[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]", "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]",
      "[[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]],[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]]", "[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]",
      "[[[[[7,7],[7,7]],[[8,7],[8,7]]],[[[7,0],[7,7]],9]],[[[[4,2],2],6],[8,7]]]", "[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]",
    ].each_slice(2) do |s, r|
      n = SnailfishNumber.from_string(s)
      n.reduce
      assert_equal r, n.inspect
    end
  end

  # This uses extra test data from https://www.reddit.com/r/adventofcode/comments/rjgfyr/2021_day_18_hint_all_explodes_and_splits_in_the/
  def test_reduce2
    l = File.readlines("testdata/18red1.d").map{|l| l.chomp}
    s = l.shift.sub("Reducing: ", "")
    n = SnailfishNumber.from_string(s)
    while r = l.shift
      nr = n.reduce_once_for_test
      # puts "\n< #{r}"
      # puts "> #{nr}"
      assert_equal r, nr
    end
  end
  def test_sum
    [
      "[[[[4,3],4],4],[7,[[8,4],9]]]", "[1,1]", "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]",
      "[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]", "[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]", "[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]",
      "[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]", "[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]", "[[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]]",
      "[[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]]", "[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]", "[[[[7,0],[7,7]],[[7,7],[7,8]]],[[[7,7],[8,8]],[[7,7],[8,7]]]]",
      "[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]", "[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]", "[[[[7,8],[6,6]],[[6,0],[7,7]]],[[[7,8],[8,8]],[[7,9],[0,6]]]]"
    ].each_slice(3) do |a,b,r|
      an = SnailfishNumber.from_string(a)
      bn = SnailfishNumber.from_string(b)
      cn = an + bn
      assert_equal r, cn.inspect
    end
  end

  def test_magnitudo
    [
      "[[1,2],[[3,4],5]]", 143,
      "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]", 1384,
      "[[[[1,1],[2,2]],[3,3]],[4,4]]", 445,
      "[[[[3,0],[5,3]],[4,4]],[5,5]]", 791,
      "[[[[5,0],[7,4]],[5,5]],[6,6]]", 1137,
      "[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]", 3488,
      "[[[[6,6],[7,6]],[[7,7],[7,0]]],[[[7,7],[7,7]],[[7,8],[9,9]]]]", 4140,
      "[[[[7,8],[6,6]],[[6,0],[7,7]]],[[[7,8],[8,8]],[[7,9],[0,6]]]]", 3993,
    ].each_slice(2) do |s, m|
      n = SnailfishNumber.from_string(s)
      assert_equal m, n.magnitudo
    end
  end
end

class SnailfishHomeworkTest < MiniTest::Test
  def test_sum_all
    [
      "a", "[[[[1,1],[2,2]],[3,3]],[4,4]]",
      "b", "[[[[3,0],[5,3]],[4,4]],[5,5]]",
      "c", "[[[[5,0],[7,4]],[5,5]],[6,6]]",
      "d", "[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]",
      "e", "[[[[6,6],[7,6]],[[7,7],[7,0]]],[[[7,7],[7,7]],[[7,8],[9,9]]]]",
    ].each_slice(2) do |t, r|
      hm = SnailfishHomework.from_test_data(t)
      assert_equal r, hm.sum_all.inspect
    end
  end
  def test_largest_pair_magnitude
    hm = SnailfishHomework.from_test_data("e")
    assert_equal 3993, hm.largest_pair_magnitude
  end
end

if MiniTest.run
  puts "Tests Passed!"

  hm = SnailfishHomework.from_data
  s = hm.sum_all
  puts "Total sum have magnitudo #{s.magnitudo}"

  hm = SnailfishHomework.from_data
  mx = hm.largest_pair_magnitude
  puts "Largest magnitudo for sum of pairs: #{mx}"
end
