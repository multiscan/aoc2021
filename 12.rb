#!/usr/bin/env ruby
require 'minitest'
require 'minitest/rg'

require './aoc.rb'

# Another option is to reorg the graph removing large caves that are just like
# extra edges and use standard Depth First Traversal (DFT) but I'll try to see
# what happens with a variation where some node cannot be flagged as visited 

class Edge
  def initialize(node, label="")
    @n = node
    @l = label
  end
  def to_s
    "#{@l}#{n.name}"
  end
end

class CaveGraph < BaseAOC
  DAY=12
  attr_reader :flashes
  def initialize(data)
    @nodes = {}
    data.lines.each do |l| 
      a,b=l.chomp.split("-")
      @nodes[a] ||= []
      @nodes[b] ||= []
      @nodes[a] << b
      @nodes[b] << a
    end
  end

  def all_paths()
    path = []
    @all_paths = []
    visited={}
    @nodes.keys.each{|n| visited[n] = false}
    all_paths_dft('start', 'end', path, visited)
    @all_paths
  end

  def all_paths_dft(fn, tn, path, visited, rl=0)
    visited[fn] = (fn =~ /^[A-Z]+$/).nil?
    path.push(fn)
    if fn == tn
      puts "New path found: #{path.join(',')}"
      @all_paths << path.join(",")
    else
      @nodes[fn].select{|n| !visited[n]}.each{|n| all_paths_dft(n, tn, path, visited, rl+1)}
    end
    path.pop
    visited[fn]=false
  end

  def ok(n, visited, path)
    c=visited[n]
    if n=="start"
      c<1
    elsif (n =~ /^[A-Z]+$/).nil?
      c<1 || c<2 && !path.select{|n| n=~ /^[a-z]+$/}.map{|n| visited[n]}.any?{|v| v>=2}
    else
      true
    end
  end


  def all_paths2()
    puts "-------------------------"
    path = []
    @all_paths = []
    visited={}
    @nodes.keys.each{|n| visited[n] = 0}
    all_paths_dft2('start', 'end', path, visited)
    @all_paths.uniq
  end

  def all_paths_dft2(fn, tn, path, visited, rl=0)
    visited[fn] = visited[fn] + 1
    path.push(fn)
    if fn == tn
      puts "New path found: #{path.join(',')}"
      @all_paths << path.join(",")
    else
      @nodes[fn].select{|n| ok(n, visited, path)}.each{|n| all_paths_dft2(n, tn, path, visited, rl+1)}
    end
    path.pop
    visited[fn]=visited[fn] - 1
  end

end

class CaveGraphTest < MiniTest::Test

  def test_graph
    dd = CaveGraph.from_test_data("a")
    ap = dd.all_paths
    assert_equal 10, ap.count

    dd = CaveGraph.from_test_data("b")
    ap = dd.all_paths
    assert_equal 19, ap.count

    dd = CaveGraph.from_test_data("c")
    ap = dd.all_paths
    assert_equal 226, ap.count

    dd = CaveGraph.from_test_data("a")
    ap = dd.all_paths2
    assert_equal 36, ap.count

    dd = CaveGraph.from_test_data("b")
    ap = dd.all_paths2
    assert_equal 103, ap.count

    dd = CaveGraph.from_test_data("c")
    ap = dd.all_paths2
    assert_equal 3509, ap.count

  end
end

if MiniTest.run
  puts "Tests Passed!"
  dd = CaveGraph.from_data
  ap = dd.all_paths
  puts "Number of paths: #{ap.count}"

  dd = CaveGraph.from_data
  ap = dd.all_paths2
  puts "Number of paths2: #{ap.count}"

end
