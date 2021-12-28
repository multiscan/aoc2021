#!/usr/bin/env ruby
require 'minitest'
require 'minitest/rg'

require './aoc.rb'

class RelDist
  attr_accessor :v, :i, :j
  def initialize(v, i, j)
    @v = v
    @i = i
    @j = j
  end
  def m
    @m ||= @v.modulo
  end
  def <=>(other)
    self.m <=> other.m
  end
  def eql?(other)
    self.m == other.m
  end
  def ==(other)
    self.m == other.m
  end
  def inspect
    "#{m}  #{i}  #{j}   #{@v.inspect}"
  end
end

class RelDistPair
  attr_reader :i, :j, :l
  def initialize(i, j, clist)
    @i = i
    @j = j
    @l = clist
  end
end

class Scanner
  attr_accessor :rotation, :position
  def initialize(s)
    @rotation = nil
    @beacons = []
    s.lines.each do |l|
      l = l.chomp
      v = l.split(",").map{|n| n.to_i}
      @beacons << Vec.new(v)
    end
  end
  def setId(i)
    @id = i
  end
  def reldist
    @rd ||= begin
      rd = []
      1.upto(@beacons.count-1) do |i|
        a = @beacons[i]
        0.upto(i-1) do |j|
          b = @beacons[j]
          rd << RelDist.new((b - a), i, j)
        end
      end
      rd.sort
    end
  end

  def beacons
    @beacons
  end

  def beacon(i)
    @beacons[i]
  end

  def absolute_beacons
    if @rotation.nil?
      @beacons
    else
      @beacons.map {|b| @rotation * b}
    end
  end

  def beacon_dist_overlap(other)
    # return al & bl
    ol = []
    i=0
    j=0

    reldist.each do |a|
      b = other.reldist.select{|b| b == a}.first
      ol << {a: a, b: b} unless b.nil?
    end
    ol
  end

  def determine_relative_rotation(other)
    ol = beacon_dist_overlap(other)
    return nil if ol.empty?
    o1 = ol.first
    va = o1[:a].v
    vb = o1[:b].v
    m = RotMat.between(va, vb)
    puts "va=#{va.inspect}   vb=#{vb.inspect}   <  #{m.to_s}"
    # verify
    sol = ol.select do |o|
      va = o1[:a].v
      vb = o1[:b].v
      m * va == vb || m * va == vb.neg
    end
    # raise "not all distances with same modulo are equivalent" unless sol.count == ol.count
    m
  end

  def determine_relative_position(other, m=RotMat.identity)
    ol = beacon_dist_overlap(other)
    puts "ol:"
    p ol
    return nil if ol.empty?
    # find two distances with the same point so we know the point
    d0 = ol[0]
    ti = d0[:a].i
    d1 = ol[1..].select{|o| o[:a].i == ti || o[:a].j == ti}.first
    puts "d0, d1:"
    p d0
    p d1
    if d0[:b].i == d1[:b].j || d0[:b].i == d1[:b].j
      oi = d0[:b].i
    else
      oi = d0[:b].j
    end


    # tb = s + ob => s = tb - ob
    ob = other.beacons[oi]
    tb = beacons[ti]
    rob = m * ob
    puts m.inspect
    puts " tb = #{tb.inspect}"
    puts " ob = #{ob.inspect}"
    puts "rob = #{rob.inspect}"
    tb - rob
  end

  def inspect
    s = "\n"
    if @rotation
      s << @rotation.inspect << "\n"
    end
    @beacons.each do |b|
      s << b.join(",") << "\n"
    end
    reldist.each{|d| s << d.inspect << "\n"}
    s
  end
end

class BeaconScanner < BaseAOC
  DAY=19
  attr_reader :scanners
  def initialize(data)
    @scanners = []
    s = ""
    data.lines.each do |l|
      l=l.chomp
      if l.empty?
        @scanners << Scanner.new(s)
      elsif l =~ /--- scanner ([0-9]+) ---/
        s = ""
      else
        s << l << "\n"
      end
    end
    unless s.empty?
      @scanners << Scanner.new(s)
    end
    @scanners.each_with_index {|s, i| s.setId(i)}
  end

  def set_rotations
    s0 = @scanners.first
    rema = []
    done = [s0]
    @scanners[1..].each do |s1|
      m = s0.determine_relative_rotation(s1)
      if m.nil?
        rema << s1
      else
        s1.rotation = m
        puts "==="
        p m
        # d = s0.determine_relative_position(s1)
        done << s1
      end
    end
    puts "Found relative   rotation for #{done.count} scanners out of #{@scanners.count}"

    rema.each do |s2|
      done.each do |s1|
        m = s1.determine_relative_rotation(s2)
        if m
          s2.rotation = s1.rotation * m
          puts "==="
          p m
          # d = s0.determine_relative_position(s1)
          break
        end
      end
      raise "scanner without rotation!!" unless s2.rotation
    end
  end

  def scanner(i)
    return @scanners[i]
  end

  def inspect
    s = ""
    @scanners.each_with_index do |c, i|
      s << "\n--- scanner #{i} ---"
      s << c.inspect
    end
    return s
  end
end

s = BeaconScanner.from_test_data
s.set_rotations


s0 = s.scanner(0)
s1 = s.scanner(1)
puts "---------------- s0:"
p s0
puts "---------------- s1:"
p s1
d = s0.determine_relative_position(s1, s1.rotation)
puts "relative position(s1): #{d.inspect}"

exit

s = BeaconScanner.from_test_data("d")
s.set_rotations


s0 = s.scanner(0)
s1 = s.scanner(1)
puts "---------------- s0:"
p s0
puts "---------------- s1:"
p s1
d = s0.determine_relative_position(s1, s1.rotation)
puts "relative position(s1): #{d.inspect}"










# ab = []
# s.scanners.each {|s| ab = ab + s.absolute_beacons}
# ab.each {|b| puts b.inspect}
# p s

# s = BeaconScanner.from_test_data
# puts "There are #{s.scanners.count} scanners"
# s1=s.scanners[0]; rd1 = s1.reldist.to_a
# s2=s.scanners[1]; rd2 = s2.reldist.to_a
# puts "rd1[0].class: #{rd1[0].class}    rd1.class=#{rd1.class}     rd1.count=#{rd1.count}"
# puts "rd2[0].class: #{rd2[0].class}    rd2.class=#{rd2.class}     rd2.count=#{rd2.count}"
#
# c = rd2 & rd1
# puts "common count #{c.count}"
# p c
#
# a = rd1
# b = rd2
# c = a & b
# p c
#
# a = [rd1[0], rd1[1], rd1[2], rd1[3]]
# b = [rd2[0], rd2[1], rd2[2], rd2[3]]
# c = a & b
# p c
#
#
# a = rd1.clone
# b = rd2.clone
# c = a & b
# p c
#
#
# a = []
# b = []
# a << rd1[0]
# a << rd1[1]
# a << rd1[2]
# a << rd1[3]
# b << rd2[0]
# b << rd2[1]
# b << rd2[2]
# b << rd2[3]
# c = a & b
# p c

# 25.times do |i|
#   puts "#{rd1[i].inspect}    #{rd2[i].inspect}"
# end
exit


# class BeaconScannerTest < MiniTest::Test
#   def test_constructor
#     s = BeaconScanner.from_test_data
#     p s
#     assert_equal 1, 0
#   end
# end
#
# if MiniTest.run
#   puts "Tests Passed!"
# end
