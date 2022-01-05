#!/usr/bin/env ruby
require 'minitest'
require 'minitest/rg'

require './aoc.rb'

# Tried to do only with intersections and with some way of compensating
# doble counting using negative cubes but it did not work

class Cube
  attr_reader :s, :xa, :xb, :ya, :yb, :za, :zb
  def initialize(xa,xb,ya,yb,za,zb)
    if xa < xb
      @xa=xa
      @xb=xb
    else
      @xa=xb
      @xb=xa
    end
    if ya < yb
      @ya=ya
      @yb=yb
    else
      @ya=yb
      @yb=ya
    end
    if za < zb
      @za=za
      @zb=zb
    else
      @za=zb
      @zb=za
    end
  end
  def count
    (1+@xb-@xa)*(1+@yb-@ya)*(1+@zb-@za)
  end
  def ==(other)
    return false if other.nil?
    @xa == other.xa && @xb == other.xb && @ya == other.ya && @yb == other.yb && @za == other.za && @zb == other.zb
  end
  def remove(other)
    r = []
    r << Cube.new(@xa,@xb,   @ya,@yb,   @za,other.za-1) unless @za == other.za                       # bottom slice
    r << Cube.new(@xa,@xb,   @ya,@yb,   other.zb+1,@zb) unless @zb == other.zb                       # top slice
    r << Cube.new(@xa,@xb,   @ya,other.ya-1,   other.za,other.zb) unless @ya == other.ya             # front stick
    r << Cube.new(@xa,@xb,   other.yb+1,@yb,   other.za,other.zb) unless @yb == other.yb             # back stick
    r << Cube.new(@xa,other.xa-1,   other.ya,other.yb,   other.za,other.zb) unless  @xa == other.xa  # left cube
    r << Cube.new(other.xb+1,@xb,   other.ya,other.yb,   other.za,other.zb) unless @xb == other.xb   # right cube
    r
  end

  def intersection(other)
    return nil if @xb < other.xa || @xa > other.xb || @yb < other.ya || @ya > other.yb || @zb < other.za || @za > other.zb

     xa,xb = [@xa,other.xa,@xb,other.xb].sort[1..2]
     ya,yb = [@ya,other.ya,@yb,other.yb].sort[1..2]
     za,zb = [@za,other.za,@zb,other.zb].sort[1..2]
     return Cube.new(xa,xb,ya,yb,za,zb)
  end

  def to_s
    "#{@xa}..#{@xb}  #{@ya}..#{@yb}  #{@za}..#{@zb} (#{self.count})"
  end
  def inspect
    self.to_s
  end
end

class Reactor < BaseAOC
  DAY=22
  attr_reader :steps, :reactor
  def initialize
    @cubes = []
  end

  def on(xa,xb,ya,yb,za,zb)
    new_cubes = []
    c = Cube.new(xa,xb,ya,yb,za,zb)
    @cubes.each do |o|
      cio = c.intersection(o)
      if cio
        new_cubes += o.remove(cio)
      else
        new_cubes << o
      end
    end
    new_cubes << c
    @cubes = new_cubes
  end

  def off(xa,xb,ya,yb,za,zb)
    new_cubes = []
    c = Cube.new(xa,xb,ya,yb,za,zb)
    @cubes.each do |o|
      cio = c.intersection(o)
      if cio
        new_cubes += o.remove(cio)
      else
        new_cubes << o
      end
    end
    @cubes = new_cubes
  end
  def count
    @cubes.inject(0) {|s,c| s + c.count}
  end
end

class RebootStep
  RSRE=/(on|off) x=(-?[0-9]+)\.\.(-?[0-9]+),y=(-?[0-9]+)\.\.(-?[0-9]+),z=(-?[0-9]+)\.\.(-?[0-9]+)/

  attr_reader :s, :xa, :xb, :ya, :yb, :za, :zb

  def initialize(line)
    m = RSRE.match(line.chomp)
    raise "Invalid reboot instruction line: #{line}" unless m
    @s=m[1]
    @xa=m[2].to_i
    @xb=m[3].to_i
    @ya=m[4].to_i
    @yb=m[5].to_i
    @za=m[6].to_i
    @zb=m[7].to_i
    @valid=true
  end

  def set_limits(xmin,xmax,ymin,ymax,zmin,zmax)
    @xa,@xb = rerange(@xa,@xb,xmin,xmax)
    @ya,@yb = rerange(@ya,@yb,ymin,ymax)
    @za,@zb = rerange(@za,@zb,zmin,zmax)
  end

  def valid?
    @valid
  end

  def to_s
    "#{@s} x=#{@xa}..#{@xb},y=#{@ya}..#{@yb},z=#{@za}..#{@zb}"
  end

  def rerange(a,b,ax,bx)
    return a,b if ax <= a && b <= bx
    return ax,bx if a < ax && bx < b
    return a,bx if ax <= a && a < bx
    return ax,b if ax <= b && b < bx
    if a > bx or b < ax
      @valid = false
      return 0,0
    end
    raise "unexpected case in rerange: #{a},#{b} in #{ax},#{bx}"
  end

end

class ReactorReboot < BaseAOC
  DAY=22
  attr_reader :steps, :reactor
  def initialize(data)
    @steps = data.lines.map do |l|
      RebootStep.new(l)
    end
    @reactor = Reactor.new
  end

  def set_limits(xmin,xmax,ymin,ymax,zmin,zmax)
    @steps.each do |s|
      s.set_limits(xmin,xmax,ymin,ymax,zmin,zmax)
    end
    @steps.select! {|s| s.valid?}
  end

  def boot
    @steps.each do |s|
      @reactor.send(s.s, s.xa, s.xb, s.ya, s.yb, s.za, s.zb)
    end
  end
end

class ReactorRebootTest < MiniTest::Test
  def test_step
    rr = ReactorReboot.from_test_data("a")
    l0 = rr.steps[0]
    l2 = rr.steps[2]
    lx = RebootStep.new("on x=-54112..-39298,y=-85059..-49293,z=-27449..7877")
    assert_equal "on x=10..12,y=10..12,z=10..12", l0.to_s
    assert_equal l0.s, "on"
    assert_equal l2.s, "off"
    assert_equal lx.s, "on"
    assert_equal 10, l0.xa
    assert_equal 12, l0.xb
    assert_equal 10, l0.ya
    assert_equal 12, l0.yb
    assert_equal 10, l0.za
    assert_equal 12, l0.zb

    l0.set_limits(-50,50,-50,50,-50,50)
    assert_equal true, l0.valid?

    lx.set_limits(-50,50,-50,50,-50,50)
    assert_equal false, lx.valid?

  end

  def test_intersection
    c1 = Cube.new(0,10,  0,10,  0,10)
    c2 = Cube.new(5,12,  6,12,  7,12)
    ce = Cube.new(5,10,  6,10,  7,10)
    ci = c1.intersection(c2)
    refute_equal nil, ci
    assert_equal ce, ci
    assert_equal 5, ci.xa
    assert_equal 10, ci.xb
    assert_equal 6, ci.ya
    assert_equal 10, ci.yb
    assert_equal 7, ci.za
    assert_equal 10, ci.zb

    c1 = Cube.new(0,10,  0,10,  0,10)
    c2 = Cube.new(12,13,  12,13,  12,13)
    ci = c1.intersection(c2)
    assert_nil ci

    c2 = Cube.new(8,12,  2,7,  4,6)
    ce = Cube.new(8,10,  2,7,  4,6)
    ci = c1.intersection(c2)
    assert_equal ce, ci
  end

  def test_remove
    c1 = Cube.new(0,10,  1,11,  2,12)
    c2 = Cube.new(3,6, 4,7, 5,8) # completely enclosed
    rr = c1.remove(c2)

    assert_equal 6, rr.count
    assert_equal rr[0], Cube.new(0,10,  1,11,  2,5-1)
    assert_equal rr[1], Cube.new(0,10,  1,11,  8+1,12)
    assert_equal rr[2], Cube.new(0,10,  1,4-1,  5,8)
    assert_equal rr[3], Cube.new(0,10,  7+1,11,  5,8)
    assert_equal rr[4], Cube.new(0,3-1,  4,7,  5,8)
    assert_equal rr[5], Cube.new(6+1,10,  4,7,  5,8)

    cr = rr.inject(0) {|s,c| s + c.count}
    ci = c2.count
    ct = c1.count
    assert_equal c1.count, cr + ci

    c1 = Cube.new(0,10,  0,10,  0,10)
    c2 = Cube.new(0,2,   4,6,   4,6)  # attached to a face
    assert_equal 11*11*11, c1.count
    assert_equal 27, c2.count
    rr = c1.remove(c2)
    assert_equal 5, rr.count
    cr = rr.inject(0) {|s,c| s + c.count}
    ci = c2.count
    ct = c1.count
    assert_equal c1.count, cr + ci

    c1 = Cube.new(0,10,  0,10,  0,10)
    c2 = Cube.new(0,2,  0,2,  0,2)    # the corner
    rr = c1.remove(c2)
    assert_equal 3, rr.count
    cr = rr.inject(0) {|s,c| s + c.count}
    ci = c2.count
    ct = c1.count
    assert_equal c1.count, cr + ci

    c1 = Cube.new(0,10,  0,10,  0,10)
    c2 = Cube.new(0,2,  0,2,  4,6)     # on an edge
    rr = c1.remove(c2)
    assert_equal 4, rr.count
    cr = rr.inject(0) {|s,c| s + c.count}
    ci = c2.count
    ct = c1.count
    assert_equal c1.count, cr + ci
  end

  def test_boot
    rr = ReactorReboot.from_test_data("a")
    rr.boot
    assert_equal 39, rr.reactor.count

    rr = ReactorReboot.from_test_data("b")
    rr.set_limits(-50,50,-50,50,-50,50)
    rr.boot
    assert_equal 590784, rr.reactor.count

    rr = ReactorReboot.from_test_data("c")
    rr.boot
    assert_equal 2758514936282235, rr.reactor.count

  end
end


if MiniTest.run
  puts "Tests Passed!"
  rr = ReactorReboot.from_data
  rr.set_limits(-50,50,-50,50,-50,50)
  puts "after set_limit there are still #{rr.steps.count} valid steps:"
  rr.steps.each do |s|
    puts s
  end
  rr.boot
  puts "There are #{rr.reactor.count} cubes that are on"

  rr = ReactorReboot.from_data
  rr.boot
  puts "There are #{rr.reactor.count} cubes that are on after full reboot process"
end
