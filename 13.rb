#!/usr/bin/env ruby
require 'minitest'
require 'minitest/rg'

require './aoc.rb'

class Origami < BaseAOC
  DAY=13
  attr_reader :flashes
  def initialize(data)
    @dots = []
    @folds = []
    data.lines.each do |l|
      if l =~ /,/
        x,y = l.chomp.split(",").map{|s| s.to_i}
        @dots << [x,y]
      elsif l=~ /fold/ 
        a,x = l.chomp.sub(/^fold along /, "").split("=")
        @folds << [a=="x" ? 0 : 1, x.to_i]
      end
    end
  end

  def fold_one(fi)
    f = @folds[fi]
    raise "invalid fold index #{fi}" if f.nil?
    a, x = f
    newdots=@dots.map do |d|
      if d[a] > x
        nd = d.clone
        nd[a] = 2 * x - nd[a]
        nd
      else
        d
      end
    end
    newdots.uniq
  end  

  def count_on_one_fold(fi)
    fold_one(fi).count
  end

  def fold!
    @folds.count.times do |fi|
      @dots = fold_one(fi)
    end
  end

  def to_s
    s = ""
    xx = @dots.map{|d| d[0]}
    yy = @dots.map{|d| d[1]}
    minx = xx.min
    maxx = xx.max
    miny = yy.min
    maxy = yy.max
    sd = @dots.sort do |d1,d2| 
      if d1[1] == d2[1]
        d1[0] <=> d2[0]
      else
        d1[1] <=> d2[1]
      end
    end
    cd = sd.shift
    puts "cd=#{cd}"
    miny.upto(maxy) do |y|
      minx.upto(maxx) do |x|
        if [x,y] == cd
          s << "#"
          cd = sd.shift
        else
          s << "."
        end
      end
      s << "\n"
    end
    s
  end

end

class OrigamiTest < MiniTest::Test

  def test_origami
    dd = Origami.from_test_data
    assert_equal 17, dd.count_on_one_fold(0)
    dd.fold!
    assert_equal """\
#####
#...#
#...#
#...#
#####
""", dd.to_s
    # assert_equal 1, 0
  end
end

if MiniTest.run
  puts "Tests Passed!"
  dd = Origami.from_data
  n = dd.count_on_one_fold(0)
  puts "After first folding instruction there are #{n} dots"

  dd.fold!
  puts dd.to_s
end
