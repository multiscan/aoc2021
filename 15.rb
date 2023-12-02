#!/usr/bin/env ruby
require 'minitest'
require 'minitest/rg'

require './aoc.rb'

class Mat < VMat
  def initialize(data, nbi, nbj)
    ll = data.lines.map {|l| l.chomp.chars.map{|v| v.to_i}}
    n0i = ll.count
    n0j = ll.first.count
    super(n0i, n0j, nbi, nbj)
    @m = ll.flatten
  end

  def get(k)
    k0 = k % @n0k
    (@m[k0] + bi(k) + bj(k) - 1)%9 + 1
  end
end

class DJStep
  attr_reader :i, :d
  include Comparable
  def initialize(index, distance)
    @i=index
    @d=distance
  end

  # note that priority is higher for shorter distances
  def <=>(other)
    other.d <=> @d 
  end

  def to_s
    @d.to_s
  end
end

class Cavern < BaseAOC
  DAY=15
  INF=(1 << 32)
  def initialize(data)
    @m = Mat.new(data, 1, 1)
  end

  def edges(k)
    @m.cross(k)
  end

  def optimal_path_cost
    path = dijkstra(@m, 0, @m.count-1)
    ritorni = 0; path.each_with_index{|k,i| ritorni = ritorni + 1 if (i>1 && k < path[i-1])}
    puts "path length: #{path.count}   ritorni=#{ritorni}"
    return path[1..].inject(0) {|s, k| s + @m.get(k)}
  end

  def optimal_path
    dijkstra(@m, 0, @m.count-1)
  end

  def dijkstra(g, src=0, tgt=g.count-1)
    return 0 if src == tgt
    seen = Array.new(g.count, false)
    prev = Array.new(g.count, nil)
    dist = Array.new(g.count, INF)

    q = PriorityQueue.new()

    dist[src] = 0
    seen[src] = true
    q.push(DJStep.new(src, 0))

    while u = q.pop
      break if u.i == tgt
      seen[u.i] = true
      edges(u.i).each do |vi|
        if !seen[vi]
          d = u.d + g.get(vi) # new total distance for pint vi
          if d < dist[vi]
            dist[vi] = d
            prev[vi] = u.i
            q.push(DJStep.new(vi, d))
          end
        end
      end
    end
    s = []
    u = tgt
    return nil if prev[u].nil?
    while u
      s << u
      u = prev[u]
    end
    s.reverse
  end

end

class Cavern5 < Cavern
  def initialize(data)
    @m = Mat.new(data, 5, 5)
  end
end

# 0123456789
# x163751742 0
# x381373672 1
# xxxxxxx328 2
# 369493xx69 3
# 7463417x11 4
# 1319128xx7 5
# 13599124x1 6
# 31254216x9 7
# 12931385xx 8
# 231194458x 9
# path: [0,10,20,21,22,23,24,25,26,36,37,47,57,58,68,78,88,89,99]
class CavernTest < MiniTest::Test
  def test_cavern0
    dd = Cavern.from_test_data('a')
    p = dd.optimal_path
    assert_equal [0, 1, 5, 9, 10, 14, 15], p
    # assert_equal 1, 0
  end 

  def test_cavern1
    dd = Cavern.from_test_data()
    c = dd.optimal_path_cost
    assert_equal 40, c
    p = dd.optimal_path
    assert_equal [0, 10, 20, 21, 22, 23, 24, 25, 26, 36, 37, 47, 57, 58, 68, 78, 88, 89, 99], p
    # assert_equal 1, 0
  end

  def test_cavern5
    dd = Cavern5.from_test_data
    c = dd.optimal_path_cost
    assert_equal 315, c
    # assert_equal 1, 0
  end
end


if MiniTest.run
  puts "Tests Passed!"
  dd = Cavern.from_data
  c = dd.optimal_path_cost
  puts "Cost of optimal path is #{c}"

  dd = Cavern5.from_data
  c = dd.optimal_path_cost
  puts "Cost of optimal path on full cavern is #{c}"

end
