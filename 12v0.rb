#!/usr/bin/env ruby
require 'minitest'
require 'minitest/rg'

require './aoc.rb'

# Another option is to reorg the graph removing large caves that are just like
# extra edges and use standard Depth First Traversal (DFT) but I'll try to see
# what happens with a variation where some node cannot be flagged as visited 

# This is the initial version which needs debugging: I think there is something
# related to pass by value instead of reference. Anyway, I decided it was 
# quicker to just rewrite it in a less nice but surely working way.

class Edge
  def initialize(node, label="")
    @n = node
    @l = label
  end
  def to_s
    "#{@l}#{n.name}"
  end
end

class Node
  attr_reader :name
  def initialize(n)
    @name = n
    @edges = []
    @large = @name =~ /^[A-Z]$/
    @small = @name =~ /^[a-z]$/
    @visited = false
  end
  def append(a)
    @edges << a unless @edges.include?(a)
  end
  def to_s
    "#{@name} connected to #{@edges.map{|e| e.name}.join(", ")}"
  end
  def large?
    @large
  end
  def small?
    @small
  end
  def start?
    @name == "start"
  end
  def end?
    @name == "end"
  end
  def visit!
    @visited = small?
  end
  def unvisit!
    @visited = false
  end
  def visited?
    @visited
  end
  def visitable_connected
    @edges.select{|n| !n.visited?}
  end
end
class CaveGraph < BaseAOC
  DAY=12
  attr_reader :flashes
  def initialize(data)
    @nodes_by_name = {}
    data.lines.each do |l| 
      an,bn=l.chomp.split("-")
      a = (@nodes_by_name[an] ||= Node.new(an))
      b = (@nodes_by_name[bn] ||= Node.new(bn))
      a.append(b)
      b.append(a)
    end
    @snode = @nodes_by_name['start']
    @enode = @nodes_by_name['end']
    @nodes_by_name.values.each do |a|
      puts a.to_s
    end
  end

  def all_paths()
    path = []
    @all_paths = []
    all_paths_dft(@snode, @enode, path)
    @all_paths
  end

  def path_to_s(path)
    path.map{|n| n.name}.join(",")
  end

  def all_paths_dft(fn, tn, path, rl="")
    fn.visit!
    path.push(fn)
    puts "#{rl} #{fn.name}(#{fn.visited? ? 'y' : 'n'})->#{tn.name}(#{tn.visited? ? 'y' : 'n'}) with #{path_to_s(path)}"
    if fn == tn
      puts "New path found: #{path_to_s(path)}"
      @all_paths << nps
    else
      rl=rl<<"  "
      fn.visitable_connected.each{|n| all_paths_dft(n, tn, path, rl)}
    end
    path.pop
    fn.unvisit!
    exit if rl>4
  end
end

class CaveGraphTest < MiniTest::Test

  def test_graph
    dd = CaveGraph.from_test_data("a")
    ap = dd.all_paths
    # p ap
    assert_equal 0, 1

  end
end

if MiniTest.run
  puts "Tests Passed!"
  dd = CaveGraph.from_data
end
