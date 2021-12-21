#!/usr/bin/env ruby
require 'minitest'
require 'minitest/rg'

require './lib/aoc.rb'

class Edge
  attr_reader :i, :w
  def initialize(ii, ww)
    @i = ii
    @w = ww
  end
  def to_s
    "n[#{@i}]=#{@w}"
  end
end

class Mat
  attr_reader :ni, :nj, :d
  def initialize(data)
    ll = data.lines.map {|l| l.chomp.chars.map{|v| v.to_i}}
    @ni = ll.count
    @nj = ll.first.count
    @m = ll.flatten
  end
  def id(i,j)
    return nil if (i<0 || i>=@ni || j<0 || j>=@nj)
    i+j*ni
  end
  def get(i,j)
    k = id(i,j)
    return nil unless k
    return Edge.new(k, @m[k])
  end
  def [](k)
    @m[k]
  end
  def inspect
    s = "-- #{@ni} x #{@nj}\n"
    @m.each_slice(@nj) do |l|
      s << l.map{|v| sprintf("%2d", v)}.join(" ") << "\n"
    end
    s
  end
  def nn(i,j)
    [[-1,0], [1,0], [0,-1], [0,1]].map{|di,dj| id(i+di, j+dj)}.compact.map{|k| @m[k]}
  end
end

class Cavern < BaseAOC
  DAY=15
  INF=(1 << 32)
  def initialize(data)

    # Build the graph risk level are like distances in edges for Dijkstra algo
    @m = Mat.new(data)
    # puts @m.inspect
    @g = []
    @m.nj.times do |j|
      @m.ni.times do |i|
        @g[@m.id(i,j)] = @m.nn(i,j)
      end
    end
  end

  def optimal_path
    path = dijkstra(@g, 0, @g.count-1)
    return [cost(path), path]
  end

  def cost(path)
    return path[1..].inject(0) {|s, k| s + @m[k].w}
  end

  def a2s(a)
    r=""
    a.each_with_index do |v,i|
      r << "#{i}:#{v} " unless v.nil? || v==INF
    end
    r
  end

  def dijkstra(g, src, tgt)
    return 0 if src == tgt
    dist = [INF] * g.count
    prev = [nil] * g.count
    dist[src] = 0
    q = (0..g.count-1).to_a
    while q.count > 0
      # u ← vertex in Q with min dist[u] from src
      u = q.min{|i,j| dist[i] <=> dist[j]}
puts "u: #{u}"
      # remove u from Q
      q = q - [u]
      break if u.i == tgt
      # for each neighbor v of u still in Q:
      g[u].each do |v|
        next unless q.include?(v.i)
        alt = dist[u] + v.w
        if alt < dist[v.i]
          dist[v.i] = alt
          prev[v.i] = u
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
# but actually the following have the same cost (and is the one chosen by dij) 
# path: [0,10,20,21,22,23,24,25,26,36,37,47,48,58,68,78,88,89,99]
class CavernTest < MiniTest::Test
  def test_dij
    dd = Cavern.from_test_data
    c, p = dd.optimal_path
    # assert_equal [0,10,20,21,22,23,24,25,26,36,37,47,57,58,68,78,88,89,99], p
    assert_equal [0,10,20,21,22,23,24,25,26,36,37,47,48,58,68,78,88,89,99], p
    assert_equal 40, c
    # assert_equal 1, 0
  end
end

if MiniTest.run
  puts "Tests Passed!"
  dd = Cavern.from_data
  c, p = dd.optimal_path
  puts "Cost of optimal path is #{c}"
end
