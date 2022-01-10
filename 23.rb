#!/usr/bin/env ruby
require 'minitest'
require 'minitest/rg'

require './aoc.rb'

# I ended up doing this by hand but sooner or later I will also implement it as a code.
# It will be a dijkstra search like for day 15 but here it is quite cumbersome
# to find all possible states from a given state. I presume the search will 
# run quite fast because of the cost of moving D amphipods is 1000 times the 
# cost of moving A amphipods.
# Don't know how to represent nicely state and how to find the connections 
# between states. There are a lot of rules to check. 
# Probably the easiest is to represent the state as a graph with 
# nodes == positions where we can scan all possible destinations of an amphipod
# with depth first search.
# Code written is stupid and mostly useless. I have to rethink this!! 
# Amphipods have to get out of their wrong room in one move get back to their
# own room in another move. It is useless to keep the all the bidirectional 
# 9edges within rooms

# Should try something like
#
#   hw                hw
#     \              / 
# hw - sx - room - dx - hw
#     /              \
# room                room
#
# each room is a stack with an extra cost for pop/push which depends on occupancy
# hallway spots are slots that can be occupied by one amphipod
# table with distances between room / hw with all other room / hw
# a move is possible if no occupied spot is closer to the origin than destination
# need to distinguish between left and right.... :_(
# Connectivity is kept on a different model: for each left/right node it keeps 
# a list of position ids / distance. In it can keep (position_id, distance, l/r)
# State is just an array of who is where.
# Still nodes of the configuration graph are quite bulky. 

# #############
# #01234567890#
# ###1#2#3#4###
#   #5#6#7#8#
#   #########
#
# in fact, connectivity can be stored in a static array of arrays
# CC = {
#  15 => 
#    [
#      {id:  1, dist: 3, lr: L}, {id: 0, dist: 4, lr: L},
#      {id:  3, dist: 3, lr: R}, {id: 4, dist: 4, lr: R},
#      {id: 12, dist: 5, lr: R} ...
#    ],
#  10 => 
#    [
#       {id: 1, dist: 2, lr: L}, {id: 0, dist: 3, lr: L}, ...
#    ],...
# }
# Occupancy is just an array: occ
# => possible destination from pos 15 on the left: 
#    fne = CC[15].sort{|a,b| a.dist <=> b.dist}.find{|c| occ[c] == EMPTY && c.lr == L}
#    CC[15].select{|c| c.dist < fne.dist && c.lr == L}
#
# or, slightly longer but already sorted

# CC = {
#  15 => 
#    l: [
#      {id:  1, dist: 3, lr: -1}, {id: 0, dist: 4, lr: -1},
#    ],
#    r: [
#      {id:  3, dist: 3, lr: +1}, {id: 4, dist: 4, lr: +1},
#      {id: 12, dist: 5, lr: +1} ...
#    ],
# note that it does not make any sense to move to the hw case above the room
# but it could be possible that an amphipods is moved temporarily to a room
# entrance
#
# => possible destination from pos 15 on the left: 
#    fne = CC[15][:l].find{|c| occ[c] != EMPTY}
#    CC[15][:l].select{|c| c.dist < fne.dist}
#     
# still quite disgusting
#
# 
# may be,instead of trying to find good data structures for applying dijkstra 
# blindly, I should simply try mimic the way I solved it by hand (similar to the 
# hannoi tower game). Well, for the moment I give up because XMax is over :_(













class BoardNode
  A2I={'A' => 0, 'B' => 1, 'C' => 2, 'D' => 3, '.' => 4}
  I2A=A2I.keys #['A', 'B', 'C', 'D', '.'];

  def initialize(current, wanted)
    @c = current.is_a?(Integer) ? current : A2I[current]
    @w = wanted.is_a?(Integer)  ? wanted  : A2I[wanted]
    raise "Invalide current value for BoardNode init" if @c.nil? || @c > 4 || @c < 0
    raise "Invalide wanted value for BoardNode init" if @w.nil? || @w > 4 || @w < 0
    # puts "init: current=#{current} (#{current.class})->#{@c}   wanted=#{wanted} (#{wanted.class})->#{@w}"
    @edges = []
  end
  def <<(other)
    @edges << other
  end
  def current
    I2A[@c]
  end
  def wanted
    I2A[@w]
  end
  def happy?
    @c == @w
  end
  def free?
    @c == 4
  end
end

# #############
# #01234567890#
# ###1#2#3#4###
#   #5#6#7#8#
#   #########
# edges:
# 0-1, 1-2, 2-11, 2-3, 3-4, 4-12, 4-5, 5-6, 6-13, 6-7, 7-8, 8-14, 8-9, 9-10
# 11-(11+4) [, 11-(11+8), 11-(11+12)]
# 12-(12+4) [, 12-(12+8), 12-(12+12)]
# 13-(13+4) [, 13-(13+8), 13-(13+12)]
# 14-(14+4) [, 14-(14+8), 14-(14+12)]
class Board
  attr_reader :nodes

  def initialize(data)
    if data.is_a?(String)
      init_from_string(data)
    else
      copy_from_other(data)
    end
    @part1 = @nodes.count < 20
    @part2 = @nodes.count > 19
    init_edges
  end

  def init_from_string(data)
    ll = data.lines.map{|l| l.chomp}[2..-2]
    @nodes=[]
    # hallway
    11.times do |i|
      p = BoardNode.new(".", ".")
      @nodes << p
    end
    # rooms
    ll.each do |l|
      4.times do |j|
        c = l[3+2*j]
        p = BoardNode.new(c,j)
        @nodes << p
      end
    end
  end

  def copy_from_other(other)
    @nodes = other.nodes.map{|n| BoardNode.new(n.current, n.wanted)}
  end

  def init_edges
    edges=[]
    # edges within hallway
    10.times do |i|
      edges << [i, i+1]
    end
    # edges between hallway and rooms
    4.times do |i|
      edges << [11+i, 2+2*i]
    end
    # edges within rooms
    (@part1 ? 1 : 3).times do |i|
      4.times do |j|
        edges << [11+4*i+j, 15+4*i+j]
      end
    end
    edges.each do |f,t|
      @nodes[f] << @nodes[t]
      @nodes[t] << @nodes[f]
    end
  end
  # configuration id to be able to compare
  def id
    @nodes.map{|p| p.current}.join("")
  end
  def target?
    if @part2
      id == "...........ABCDABCDABCDABCD"
    else
      id == "...........ABCDABCD"
    end
  end

  def to_s
    s =  "\n#############\n"
    s << "#"
    @nodes[0..10].each {|n| s << n.current }
    s << "#\n"
    s << "###"; @nodes[11..14].each {|n| s << n.current; s << "#" }; s << "##\n"
    s << "  #"; @nodes[15..18].each {|n| s << n.current; s << "#" }; s << "\n"
    if @part2
      s << "  #"; @nodes[19..22].each {|n| s << n.current; s << "#" }; s << "\n"
      s << "  #"; @nodes[23..26].each {|n| s << n.current; s << "#" }; s << "\n"
    end
    s << "  #########\n"
    s
  end

  def inspect
    "#{@nodes.count} nodes: #{id}"
  end
end

class AmphipodOrganizer < BaseAOC
  DAY=23
  attr_reader :board
  def initialize(data)
    @board = Board.new(data)
  end
end

# class AmphipodOrganizer < MiniTest::Test
# end

b = AmphipodOrganizer.from_test_data("a").board
puts b

bcopy = Board.new(b)
puts bcopy
exit

if MiniTest.run
  puts "Tests Passed!"
end
