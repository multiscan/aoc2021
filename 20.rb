#!/usr/bin/env ruby
require 'minitest'
require 'minitest/rg'

require './aoc.rb'

# 5488, 5479

class TrenchMap < BaseAOC
  DAY=20
  OFFS=800
  NN = [
      -1,-1, -1,0, -1,1,
       0,-1,  0,0,  0,1,
       1,-1,  1,0,  1,1
     ]

  def initialize(data)
    ll=data.lines.map{|l| l.chomp}
    @code=ll.first.tr("#.", "10").chars.map{|s| s.to_i}
    img=ll[2..].map{|l| l.tr("#.", "10")}

    @image={}
    @current_generation = 0
    img.each_with_index do |y, iy|
      y.chars.each_with_index do |x, ix|
        if x == '1'
          k=c2k(iy+OFFS,ix+OFFS)
          @image[k] = 1
        end
      end
    end
    update_bbox
  end

  def to_s
    s = "Number of pounds: #{@image.count}    bbox: #{@imin},#{@jmin} - #{@imax},#{@jmax}"
  end

  def plot
    s=""
    @imin.upto(@imax) do |i|
      @jmin.upto(@jmax) do |j|
        c = pv(i,j) == 1 ? '#' : '.'
        s << c
      end
      s << "\n"
    end
    s
  end

  def inspect
    s = "Generation: #{@current_generation}     Number of pounds: #{@image.count}    bbox: #{@imin},#{@jmin} - #{@imax},#{@jmax}\n\n"
    s << plot
    s
  end

  def count
    @image.count
  end

  def update_bbox
    kk = @image.keys.map{|k| k2c(k)[0]}
    @imin = kk.min
    @imax = kk.max
    kk = @image.keys.map{|k| k2c(k)[1]}
    @jmin = kk.min
    @jmax = kk.max
  end

  # 0 version when I thought that also the rest of the infinite image had
  # to be updated. In that case, everything depended on the value of @code[0]
  # and @code[512] if evertything outside the bb is blinkink or stable
  def pv0(i,j)
    if @imin <= i && i <= @imax && @jmin <= j && j <= @jmax
      k=c2k(i,j)
      @image.key?(k) ? @image[k] : 0
    else
      fc=@code[0]
      lc=@code[511]
      if fc == 1
        if lc == 0
          @current_generation % 2
        else
          1
        end
      else
        if lc == 0
          (@current_generation+1 % 2)
        else
          0
        end
      end
    end
  end

  def enhance0
    nimage={}
    kk = []
    @image.keys.each do |k|
      i,j=k2c(k)
      kk = kk + nn(i,j)
    end
    kk.uniq.each do |i ,j|
      a = nn(i,j).map{|ni,nj| self.pv0(ni,nj)}.join('').to_i(2)
      v = @code[a]
      # puts "#{i-OFFS},#{j-OFFS}: #{pv(i,j)}"
      # nn(i,j).map{|ni,nj| self.pv(ni,nj)}.each_slice(3){|s| puts "    #{s.join('').tr('10', '#.')}"}
      # puts "    #{a} -> #{v}"
      if v == 1
        nimage[c2k(i,j)] = 1
      end
    end
    @image = nimage
    update_bbox
    @current_generation = @current_generation + 1
  end

  def pv(i,j)
    k=c2k(i,j)
    @image.key?(k) ? 1 : 0
  end

  def enhance
    nimage={}
    (@imin-1).upto(@imax+1) do |i|
      (@jmin-1).upto(@jmax+1) do |j|
        a = nn(i,j).map{|ni,nj| self.pv(ni,nj)}.join('').to_i(2)
        v = @code[a]
# puts "#{i-OFFS},#{j-OFFS}: #{pv(i,j)}"
# nn(i,j).map{|ni,nj| self.pv(ni,nj)}.each_slice(3){|s| puts "    #{s.join('').tr('10', '#.')}"}
# puts "    #{a} -> #{v}"
        if v == 1
          nimage[c2k(i,j)] = 1
        end
      end
    end
    @image = nimage
    update_bbox
    @current_generation = @current_generation + 1
  end


  def nn(i,j)
    NN.each_slice(2).map{|di,dj| [i+di, j+dj]}
  end
  def c2k(i,j)
    "#{i}_#{j}"
  end
  def k2c(k)
    k.split("_").map{|s| s.to_i}
  end
end

class TrenchMapTest < MiniTest::Test
  def test_init
    tm = TrenchMap.from_test_data("a")
    assert_equal 10, tm.count
    assert_equal "#..#.\n#....\n##..#\n..#..\n..###\n", tm.plot
  end
  def test_enhance
    tm = TrenchMap.from_test_data("a")
    tm.enhance
    assert_equal 24, tm.count
    assert_equal ".##.##.\n#..#.#.\n##.#..#\n####..#\n.#..##.\n..##..#\n...#.#.\n", tm.plot
    tm.enhance
    assert_equal 35, tm.count
  end
  def test_enhance0
    tm = TrenchMap.from_test_data("a")
    tm.enhance0
    assert_equal 24, tm.count
    assert_equal ".##.##.\n#..#.#.\n##.#..#\n####..#\n.#..##.\n..##..#\n...#.#.\n", tm.plot
    tm.enhance0
    assert_equal 35, tm.count
  end
end

if MiniTest.run
  puts "Tests Passed!"
  tm = TrenchMap.from_data
  tm.enhance0
  tm.enhance0
  puts "After 2 enhancements there are #{tm.count} bright dots (with enhance0)"
  tm = TrenchMap.from_data
  tm.enhance
  tm.enhance
  puts "After 2 enhancements there are #{tm.count} bright dots (with enhance)"
end
