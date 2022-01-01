#!/usr/bin/env ruby
require 'minitest'
require 'minitest/rg'

require './aoc.rb'

class M4D
  def initialize(n1,n2,n3,n4,v0=0)
    @rr = n1*n2*n3*n4
    @d = [v0]*@rr
    @r1 = n1 - 1
    @r2 = n2 - 1
    @r3 = n3 - 1
    @r4 = n4 - 1
    @s1 = n2*n3*n4
    @s2 = n3*n4
    @s3 = n4
    @s4 = 1
  end

  def reset(v)
    @rr.times {|i| @d[i] = v}
  end

  def ii(i1,i2,i3,i4)
    i1 * @s1 + i2 * @s2 + i3 * @s3 + i4 # * s4
  end
  def v(i1,i2,i3,i4)
    @d[ii(i1,i2,i3,i4)]
  end

  def set(i1,i2,i3,i4,v)
    @d[ii(i1,i2,i3,i4)] = v
  end

  def add(i1,i2,i3,i4,v)
    i = ii(i1,i2,i3,i4)
    @d[i] = @d[i] + v
  end

  def mulset(i1,i2,i3,i4,v)
    r1 = i1.nil? ? (0..@r1) : (i1..i1)
    r2 = i1.nil? ? (0..@r2) : (i2..i2)
    r3 = i1.nil? ? (0..@r3) : (i3..i3)
    r4 = i1.nil? ? (0..@r4) : (i4..i4)
    r1.each do |j1|
      r2.each do |j2|
        r3.each do |j3|
          r4.each do |j4|
            i = ii(j1, j2, j3, j4)
            @d[i] = v
          end
        end
      end
    end
  end

  def muladd(i1,i2,i3,i4,v)
    r1 = i1.nil? ? (0..@r1) : (i1..i1)
    r2 = i1.nil? ? (0..@r2) : (i2..i2)
    r3 = i1.nil? ? (0..@r3) : (i3..i3)
    r4 = i1.nil? ? (0..@r4) : (i4..i4)
    r1.each do |j1|
      r2.each do |j2|
        r3.each do |j3|
          r4.each do |j4|
            i = ii(j1, j2, j3, j4)
            @d[i] = @d[i] + v
          end
        end
      end
    end
  end
end

class DeterministicDice
  def initialize
    @c=0
    @n=0
  end
  def roll
    r = @c + 1
    @c = (@c + 1)%100
    @n = @n + 1
    r
  end
  def nrols
    @n
  end
end

class DiracGame < BaseAOC
  DAY=21
  # dice outcomes (occurences in all possible sums of 1,2,3)
  QS = {
    3 => 1,
    4 => 3,
    5 => 6,
    6 => 7,
    7 => 6,
    8 => 3,
    9 => 1
  }
  NPOS = 10
  SCOREX = 21

  attr_reader :wins1, :wins2, :cs, :nworlds, :sh

  def initialize(data)
    @ww = []
    @ww[0] = M4D.new(NPOS,SCOREX,NPOS,SCOREX,0)
    @ww[1] = M4D.new(NPOS,SCOREX,NPOS,SCOREX,0)
    p1 = Player.new(data.lines[0])
    p2 = Player.new(data.lines[1])
    @wins1 = 0
    @wins2 = 0
    # We start with one single world where players have their respective initial position and zero score
    @ww[0].set(p1.pos-1,0,p2.pos-1,0,1)
    @cs = 0
    @playing = 0
    @sh = compute_score_histo(0)
  end
  def done?
    @tt == 0
  end

  # TODO we now that after each step the minumum score is increased by 1
  def step1
    oww = @ww[0]
    nww = @ww[1]
    nww.reset(0)
    QS.each do |c,n| # c=sum of dice values ; n=multiplicity
      NPOS.times do |p1|
        new_p = ( p1 + c ) % 10
        SCOREX.times do |s1|
          new_s = s1 + new_p + 1
          if new_s >= SCOREX
            NPOS.times do |p2|
              SCOREX.times do |s2|
                nv = n * oww.v(p1,s1,p2,s2)
                @wins1 = @wins1 + nv
              end
            end
          else
            NPOS.times do |p2|
              SCOREX.times do |s2|
                nv = n * oww.v(p1,s1,p2,s2)
                nww.add(new_p,new_s,p2,s2,nv)
              end
            end
          end
        end
      end
    end
  end

  def step2
    oww = @ww[1]
    nww = @ww[0]
    nww.reset(0)
    QS.each do |c,n|
      NPOS.times do |p2|
        new_p = ( p2 + c ) % 10
        SCOREX.times do |s2|
          new_s = s2 + new_p + 1
          if new_s >= SCOREX
            NPOS.times do |p1|
              SCOREX.times do |s1|
                nv = n * oww.v(p1,s1,p2,s2)
                @wins2 = @wins2 + nv
              end
            end
          else
            NPOS.times do |p1|
              SCOREX.times do |s1|
                nv = n * oww.v(p1,s1,p2,s2)
                nww.add(p1,s1,new_p,new_s,nv)
              end
            end
          end
        end
      end
    end
  end

  def step
    @cs = @cs + 1
    step1
    compute_score_histo(0)
    unless done?
      step2
      compute_score_histo(1)
    end
    return !done?
  end

  def play
    while @playing > 0
      step
    end
    return @wins1, @wins2
  end

  def compute_score_histo(i=0)
    @sh = []
    @playing = 0
    21.times{@sh << [0,0]}
    NPOS.times do |p1|
      SCOREX.times do |s1|
        NPOS.times do |p2|
          SCOREX.times do |s2|
            v = @ww[i].v(p1,s1,p2,s2)
            @playing = @playing + v
            @sh[s1][0] = @sh[s1][0] + v
            @sh[s2][1] = @sh[s2][1] + v
          end
        end
      end
    end
    @sh
  end

  def inspect
    out = "wins1: #{@wins1}   wins2: #{@wins2}   playing: #{@playing}\n"
    SCOREX.times do |s|
      out << sprintf("%2d   %20d  %20d\n", s, @sh[s][0], @sh[s][1]);
    end
    out
  end
end

class Player
  PRE = /^Player ([0-9]+) starting position: ([0-9]+)$/
  def initialize(l)
    # Player 1 starting position: 4
    m = PRE.match(l.chomp)
    p0 = m[2].to_i
    @id = m[1].to_i
    @p = p0 - 1
    @s = 0
  end
  def score
    @s
  end
  def pos
    @p + 1
  end
  def id
    @id
  end
  def avance(c)
    @p = (@p + c)%10
    @s = @s + @p + 1
  end
  def wins?
    @s>=1000
  end
end

class DeterministicDiracGame < BaseAOC
  DAY=21
  def initialize(data)
    @pp = data.lines.select{|l| l=~ /^Player/}.map{|l| Player.new(l)}
    @pp.each do |p|
      puts "Player #{p.id} starting position: #{p.pos}"
    end
  end

  def play1000
    d = DeterministicDice.new
    while !@pp.any?{|p| p.wins?}
      @pp.each do |p|
        a1 = d.roll
        a2 = d.roll
        a3 = d.roll
        a = a1 + a2 + a3
        p.avance(a)
        if p.wins?
          puts "Player #{p.id} rolls #{a1}+#{a2}+#{a3} and moves to space #{p.pos} for a final score of #{p.score}."
          break
        else
          puts "Player #{p.id} rolls #{a1}+#{a2}+#{a3} and moves to space #{p.pos} for a total score of #{p.score}."
        end
      end
    end
    looser = @pp.select{|p| !p.wins?}[0]
    puts "Looser score: #{looser.score}"
    puts "Total number of dice rols: #{d.nrols}"
    return looser.score * d.nrols
  end
end

class DiracGameTest < MiniTest::Test
  def test_play1000
    g = DeterministicDiracGame.from_test_data
    s = g.play1000
    assert_equal 739785, s
  end

  def test_game
    g = DiracGame.from_test_data
    w1,w2=g.play
    assert_equal 444356092776315, w1
    assert_equal 341960390180808, w2
  end
end

if MiniTest.run
  puts "Tests Passed!"

  g = DeterministicDiracGame.from_data
  s = g.play1000
  puts "Looser's score * dice rols = #{s}"

  g = DiracGame.from_data
  w1,w2=g.play
  wx=[w1,w2].max
  puts "In Dirac Game, the player that wins in more universes wins in #{wx} universes"

end
