#!/usr/bin/env ruby
require 'minitest'
require 'minitest/rg'

require './aoc.rb'

class Alu
  VRE=/^[wxyz]$/
  def initialize(inp)
    @sn = inp
    @v = {
      "w" => 0,
      "x" => 0,
      "y" => 0,
      "z" => 0,
    }
  end

  def w
    @v["w"]
  end

  def x
    @v["x"]
  end

  def y
    @v["y"]
  end

  def z
    @v["z"]
  end

  def execute(s)
    cmd, op1, op2 = s.split(" ")
    n = op2 =~ VRE ? @v[op2] : op2.to_i
    # puts "#{s} -> cmd='#{cmd}'    op1=#{op1}   op2=#{op2}    n=#{n}"
    self.send cmd, op1, n
    # puts "     => w=#{w}  x=#{x}  y=#{y}  z=#{z}"
  end

  def inp(op1, op2)
    @v[op1] = @sn.shift
  end

  def add(op1, op2)
    @v[op1] = @v[op1] + op2
  end

  def div(op1, op2)
    @v[op1] = @v[op1] / op2
  end

  def mul(op1, op2)
    @v[op1] = @v[op1] * op2
  end

  def mod(op1, op2)
    @v[op1] = @v[op1] % op2
  end

  def eql(op1, op2)
    @v[op1] = (@v[op1] == op2) ? 1 : 0
  end
end

class CParams
  attr_reader :a, :b, :c
  def initialize(ll)
    @a = ll[4].split(" ").last.to_i
    @b = ll[5].split(" ").last.to_i
    @c = ll[15].split(" ").last.to_i
  end

  def inspect
    "a=#{a}   b=#{b}   c=#{c}"
  end
end

class AluProgram < BaseAOC
  DAY=24
  def initialize(data)
    @program = data.lines.map{|l| l.chomp}
  end

  def run(n)
    a = Alu.new(n)
    @program.each do |l|
      a.execute(l)
    end
    return a.w, a.x, a.y, a.z
  end

  def run14digits(n)
    nn = sprintf("%014d", n).chars.map{|c| c.to_i}
    p nn
    run nn
  end
end

class Program < AluProgram
  # DAY=24
  def initialize(data)
    super data
    c=-1
    d=[]
    @program.each do |l|
      if l =~ /inp w/
        c += 1
        d[c] = []
      end
      d[c] << l
    end
    @params = d.map{|ll| CParams.new(ll)}
    puts "--------------------------------------------------- params:"
    @params.each_with_index do |p,i|
      printf "%2d  %5d   %5d   %5d\n", i, p.a,  p.b, p.c
    end
  end

  def run(nn)
    z = 0
    nn.each_with_index do |c,i|
      z = zp(i,c,z)
    end
    z
  end

  #  dgt    a       b       c
  # -------------------------
  #  0      1      12       4
  #  1      1      11      10
  #  2      1      14      12
  #  3     26      -6      14
  #  4      1      15       6
  #  5      1      12      16
  #  6     26      -9       1
  #  7      1      14       7
  #  8      1      14       8
  #  9     26      -5      11
  # 10     26      -9       8
  # 11     26      -5       3
  # 12     26      -2       1
  # 13     26      -7       8
  def zp(i,w,z0=0)
    p = @params[i]
    x = z0 % 26 + p.b
    z = z0 / p.a
    unless x == w
      z = z * 26 + w + p.c
    end
    # printf "%2d  %3d  %3d  %3d  < %1d / %10d (x=%2d) => %10d\n", i, p.a, p.b, p.c, w, z0, z0%26+p.b, z
    return z
  end

  # In fact, given the input parameters, when we have p.a == 1 then
  # x is always > 9 and the condition x == w never met
  # Therefore, we have to try matching the condition when p.a == 26 so that
  # z is reduced instead of being kept of the same order
  # Whenever p.a == 26 instead of the loop, I compute w so that x == w

  def range_down(i,z0=0)
    p = @params[i]
    if p.a == 1
      r = 9.downto(1).to_a
    else
      x = z0 % 26 + p.b
      if x > 0 && x < 10
        r = [x]
      else
        r = 9.downto(1).to_a
      end
    end
    return r
  end

  def range_up(i,z0=0)
    p = @params[i]
    if p.a == 1
      r = 1.upto(9).to_a
    else
      x = z0 % 26 + p.b
      if x > 0 && x < 10
        r = [x]
      else
        r = 1.upto(9).to_a
      end
    end
    return r
  end

  def solve_iter(i,z0,range)
    method(range).call(i,z0).each do |w|
      z = zp(i,w,z0)
      if i<13
        r = solve_iter(i+1,z,range)
        return r << w unless r.nil?
      else
        return [w] if z == 0
      end
    end
    return nil
  end

  def solve(range = :range_down)
    r = solve_iter(0,0,range)
    return r.nil? ? "not found" : r.reverse.join("")
  end


end # class

class AluProgramTest < MiniTest::Test
  def test_program
    p = AluProgram.from_test_data("a")
    [
      "1111",
      "1010",
      "0101",
      "0011",
      "0001",
      "0000",
    ].each do |s|
      w,x,y,z = p.run([s.to_i(2)])
      assert_equal s, "#{w}#{x}#{y}#{z}"
    end
  end

  def test_program2
    # check that reverse engineering of the code works
    p0 = AluProgram.from_data
    p2 = Program.from_data
    20.times do
      n = ([0]*14).map{|i| rand(1..9)}.join("").to_i
      puts "------------------- #{n}"
      w,x,y,z0 = p0.run14digits(n)
      z2 = p2.run14digits(n)
      assert_equal z0, z2
    end
  end
end

if MiniTest.run
  puts "Tests Passed!"

  # ap = Program.from_data
  # r = ap.solve(:range_up)
  # puts "Largest valid code: #{r}"

  ap = Program.from_data
  r = ap.solve(:range_up)
  puts "Largest valid code: #{r}"

end
