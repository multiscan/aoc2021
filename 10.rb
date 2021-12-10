#!/usr/bin/env ruby

require 'minitest'
require 'minitest/rg'

require './aoc.rb'

class Line
  OCL=['(', '[', '{', '<']
  CC={
    '(' => ')',
    '[' => ']',
    '{' => '}',
    '<' => '>',
  }
  CCL=CC.values
  FICSCORES={
    ')' => 3,
    ']' => 57,
    '}' => 1197,
    '>' => 25137
  }
  COMPSCORES = {
    ')' => 1,
    ']' => 2,
    '}' => 3,
    '>' => 4,
  }
  attr_reader :score, :completion_score
  def initialize(line)
    @line = line.chomp;
    fic = first_illegal_char
    if fic.nil?
      @score = 0
    else
      @score = FICSCORES[fic]
    end
    @completion=self.complete
    @completion_score = compute_completion_score
  end

  def corrupted?
    @score > 0
  end

  def completion_string
    @completion.join('')
  end

  def first_illegal_char
    ocs=[]   # stack with currently open tags
    ccc=nil  # next closing tag that we expect to find
    coc=nil
    @line.chars.each do |c|
      if OCL.include?(c)
        ocs.push(coc) unless coc.nil?
        coc = c
        ccc = CC[coc]
      else
        if CCL.include?(c)
          if c == ccc
            coc=ocs.pop
            ccc=CC[coc]
          else  
            return c
          end
        end
      end
    end
    return nil
  end

  def complete
    return [] if self.corrupted?
    ocs=[]   # stack with currently open tags
    ccc=nil  # next closing tag that we expect to find
    coc=nil  # current opening tag
    @line.chars.each do |c|
      if OCL.include?(c)
        ocs.push(coc) unless coc.nil?
        coc = c
        ccc = CC[coc]
      else
        if c == ccc
            coc=ocs.pop
            ccc=CC[coc]
        else  
          raise "Unexpected char: looks like the line is corrupted"
        end
      end
      # line needs to be completed
    end
    if ocs.count > 0
      ocs.push(coc)
      closing_tags = ocs.map{|c| CC[c]}.reverse
      # puts "incomplete line: #{@line}  complete with #{closing_tags.join('')}"
      return closing_tags
    else
      []
    end
  end

  def compute_completion_score()
    @completion.inject(0) do |s, c|
      s * 5 + COMPSCORES[c]
    end
  end
end

class Linter < BaseAOC
  DAY=10
  attr_reader :lines
  def initialize(data)
    @lines = data.lines.map {|l| Line.new(l)}
    @incompleteLines = @lines.select{|l| !l.corrupted? }
  end
  def corruption_score
    @lines.inject(0) { |s,l| s+l.score }
  end
  def middle_score
    ss=@incompleteLines.map{|l| l.completion_score}.sort
    ss[ss.count/2]
  end
end

class LinterTest < MiniTest::Test
  def test_corruption
    dd = Linter.from_test_data
    assert_equal false, dd.lines[0].corrupted?
    assert_equal true, dd.lines[2].corrupted?
    assert_equal 1197, dd.lines[2].score
    assert_equal 26397, dd.corruption_score
    assert_equal "}}]])})]", dd.lines[0].completion_string
    assert_equal 294, dd.lines[9].completion_score
    assert_equal 288957, dd.middle_score
  end
end

if MiniTest.run
  puts "Tests Passed!"
  dd = Linter.from_data
  puts "Curruption score: #{dd.corruption_score}"
  puts "Completion score: #{dd.middle_score}"
end
