#!/usr/bin/env ruby
require 'minitest'
require 'minitest/rg'

require './aoc.rb'

class Packet < BaseAOC
  DAY=16

  attr_reader :m, :version, :type_id, :len
  def initialize(data)
    @m = data.chomp.scan(/.{1,2}/).map{|c| c.to_i(16)}
    @mbin = @m.map{|c| c.to_s(2)}.map{|c| "0"*(8-c.length) << c}.join('')
    @nbitx = @m.size * 8
    @cursor = 0
    @version = read(3)
    @type_id = read(3)
    @sub_packets = []
    @len_type = read(1)
    if @len_type == 1
      @len = read(11)
      @sub_packets << read(11)
      @sub_packets << read(16)
    else
      # if bit 7 is 0 then len is next 15 bits
      @len = read(15)
      @len.times do
        @sub_packets << read(11)
      end
    end
  end

  def read(count)
    if @cursor < @nbitx - count
      r = sub(@cursor, count)
      s = r.to_s(2)
      puts "read #{count} => #{s.length}: #{'0'*(count - s.length)}#{s}"
    else
      r = nil
    end
    @cursor = @cursor + count
    return r
  end

  def sub(fbit,count)
    @mbin[fbit..fbit+count-1].to_i(2)
  end

  # def sub(fbit,count)
  #   lbit = fbit + count - 1 
  #   fbyte = fbit/8
  #   lbyte = lbit/8
  #   lbits = fbit
  #   rbits = 7 - lbit%8
  #   s = 0
  #   # puts "\nfbit:  #{fbit}   count: #{count}   lbit=#{lbit}"
  #   # puts "fbyte: #{fbyte} / #{@m.size}"
  #   # puts "lbyte: #{lbyte} / #{@m.size}"
  #   # puts "rbits: #{rbits}"
  #   # puts "lbits: #{lbits}"
  #   bb = @m[fbyte..lbyte]
  #   bbs = bb.map{|b| b.to_s(2)}.join(" ")
  #   # puts "bytes: #{bbs}"
  #   fbm = (1<<(8-lbits))-1
  #   # puts "fbm:   #{fbm.to_s(2)}"
  #   bb[0] = bb[0] & fbm
  #   # puts "first_byte: #{bb[0].to_s(2)}"
  #   bb.reverse.each_with_index{|v,i| s = s | (v << (8*i))}
  #   s = s >> rbits
  #   # puts "s:     #{s.to_s(2)}"
  #   s
  # end
end

class PacketTest < MiniTest::Test
  def test_packet0
    # dd = Packet.new("000102030405060708090A0B0C0D0E0F10FF")
    # assert_equal [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,255], dd.m

    dd = Packet.new("EE00D40C823060")
    assert_equal "111", dd.sub(0,3).to_s(2)
    assert_equal "101", dd.sub(2,3).to_s(2)
    assert_equal "1100", dd.sub(42,4).to_s(2)
    assert_equal "100000000011010", dd.sub(6,15).to_s(2)

    assert_equal 7, dd.version
    assert_equal 3, dd.type_id
    assert_equal 3, dd.len


    dd = Packet.new("38006F45291200")
    assert_equal 1, dd.version
    assert_equal 6, dd.type_id
    assert_equal 27, dd.len


    dd = Packet.new("8A004A801A8002F478")
    assert_equal 4, dd.version
    

# puts "0          1          2          3           4          5"
# puts "01234567 89012345 67890123 45678901 23456789 01234567 89012345"
# puts "11101110 00000000 11010100 00001100 10000010 00110000 01100000"
# m = Packet.new("EE00D40C823060")
# b = 
# puts "sub(0,2) = #{m.sub(0,2).to_s(2)}"
# puts "sub(2,4) = #{m.sub(2,4).to_s(2)}"
# puts "sub(6,20) = #{m.sub(6,20).to_s(2)}"







    assert_equal 1, 0
  end 
end


if MiniTest.run
  puts "Tests Passed!"
end
