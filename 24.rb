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
    "a=#{a}   b=#{b}    c=#{c}"
  end
end

class Program < BaseAOC
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

# This one was simple but it might take 9M seconds to finish :_(
class Program2 < Program
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
  #  0      1      12       4     -> z0 = w0 + c0
  #  1      1      11      10     -> z1 = z0 * 26 + w1 + c1     c1>9 => z%26 > 9 != w2
  #  2      1      14      12     -> z2 = z1 * 26 + c2 + w2     c2>9 => z%26 > 9 != w3
  #  3     26      -6      14     -> z3 = z2/26 = z1   if w3 == c2 + w2 + b3 => w3 = w2 + 11 - 6   => w3 = w2 + 5 or w2 = w3 - 5 = 4 (assuming w3=9 max value)
  #  4      1      15       6     -> z4 = z1 * 26 + w4 + c4
  #  5      1      12      16     -> z5 = z4 * 26 + w5 + c5
  #  6     26      -9       1     -> z6 = z5/26 = z4   if w6 == w5 + c5 + b6 => w6 = w5 + 16 - 9   => w6 = w5 + 7 or w5 = w6 - 7 = 2 (assuming w6=9 max value)
  #  7      1      14       7     -> z7 = z4 * 26 + w7 + c7
  #  8      1      14       8     -> z8 = z7 * 26 + w8 + c8
  #  9     26      -5      11     -> z9 = z8/26 = z7   if w9 == w8 + c8 + b9 => w9 = w8 + 8 - 5    => w9 = w8 + 3 or w8 = w9 - 3 = 6  (assuming w9=9 max value)
  # 10     26      -9       8     ->
  # 11     26      -5       3     -> z = z/26 = z0
  # 12     26      -2       1     -> z = z/26 = 0
  # 13     26      -7       8     -> z = z/26 = 0

# w0 = 9
# w1 = 9
# w2 = 9
# w3 = 4
# w4 = 9
# w5 = 2
# w6 = 9
# w7 = 9
# w8 = 3
# w9 = 9


  #
  # conditions for z==0:
  #
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

  def solve
    i0 = 9
    z0 = zp(0,i0,0)
    puts "z0=#{z0}"
    i1 = 9
    z1 = zp(1,i1,z0)
    puts "z1=#{z1}"
    i2 = 9
    z2 = zp(2,i2,z1)
    puts "z2=#{z2}"
    i3 = 4
    z3 = zp(3,i3,z2)
    puts "z3=#{z3}"
    i4 = 9
    z4 = zp(4,i4,z3)
    puts "z4=#{z4}"

    9.downto(1).each do |i5|
      z5 = zp(5,i5,z4)
      9.downto(1).each do |i6|
        z6 = zp(6,i6,z5)
        puts "z6=#{z6}"
        9.downto(1).each do |i7|
          z7 = zp(7,i7,z6)
          # puts "z7=#{z7}"
          9.downto(1).each do |i8|
            z8 = zp(8,i8,z7)
            # puts "z8=#{z8}"
            9.downto(1).each do |i9|
              z9 = zp(9,i9,z8)
              # puts "z9=#{z9}"
              9.downto(1).each do |i10|
                z10 = zp(10,i10,z9)
                9.downto(1).each do |i11|
                  z11 = zp(11,i11,z10)
                  9.downto(1).each do |i12|
                    z12 = zp(12,i12,z11)
                    9.downto(1).each do |i13|
                      z13 = zp(13,i13,z12)
                      # gets
                      if z13 == 0
                        puts "Found: #{i0}#{i1}#{i2}#{i3}#{i4}#{i5}#{i6}#{i7}#{i8}#{i9}#{i10}#{i11}#{i12}#{i13}"
                        return [i0,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12,i13]
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    puts "Not found"
    return [0,0,0,0,0,0,0,0,0,0,0,0,0,0]
  end

  def solve0
    9.downto(1).each do |i0|
      z0 = zp(0,i0,0)
      9.downto(1).each do |i1|
        z1 = zp(1,i1,z0)
        9.downto(1).each do |i2|
          z2 = zp(2,i2,z1)
          9.downto(1).each do |i3|
            z3 = zp(3,i3,z2)
            9.downto(1).each do |i4|
              z4 = zp(4,i4,z3)
              9.downto(1).each do |i5|
                z5 = zp(5,i5,z4)
                9.downto(1).each do |i6|
                  z6 = zp(6,i6,z5)
                  9.downto(1).each do |i7|
                    z7 = zp(7,i7,z6)
                    9.downto(1).each do |i8|
                      z8 = zp(8,i8,z7)
                      9.downto(1).each do |i9|
                        z9 = zp(9,i9,z8)
                        9.downto(1).each do |i10|
                          z10 = zp(10,i10,z9)
                          9.downto(1).each do |i11|
                            z11 = zp(11,i11,z10)
                            9.downto(1).each do |i12|
                              z12 = zp(12,i12,z11)
                              9.downto(1).each do |i13|
                                z13 = zp(13,i13,z12)
                                gets
                                return [i0,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12,i13] if z13 == 0
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

end

class AluProgramTest < MiniTest::Test
  def test_program
    p = Program.from_test_data("a")
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
    p0 = Program.from_data
    p2 = Program2.from_data
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
  # ap = AluProgram.from_data(24)
  ap = Program2.from_data
  r = ap.solve
  p r
  puts "Largest valid code: #{r.join('')}"
end
