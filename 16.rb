#!/usr/bin/env ruby
require 'minitest'
require 'minitest/rg'

require './aoc.rb'

class Socket
  attr_reader :cursor

  def initialize(data)
    @m = data.chomp.scan(/.{1,2}/).map{|c| c.to_i(16)}
    @mbin = @m.map{|c| c.to_s(2)}.map{|c| "0"*(8-c.length) << c}.join('')
    @nbitx = @m.size * 8
    @cursor = 0
  end

  def remaining
    @nbitx - @cursor
  end

  def read(count)
    if @cursor <= @nbitx - count
      r = sub(@cursor, count)
      s = r.to_s(2)
      # puts "read #{count} => #{s.length}: #{'0'*(count - s.length)}#{s}"
    else
      r = nil
    end
    @cursor = @cursor + count
    return r
  end

  def sub(fbit,count)
    @mbin[fbit..fbit+count-1].to_i(2)
  end

  def to_s
    "socket pos #{@cursor} / #{@nbitx}"
  end
end

class Packet
  attr_reader :len, :version, :type_id, :value, :sub_packets
  def initialize(s)
    @socket = s
    start = @socket.cursor
    @value = nil
    @sub_packets = []
    @version = @socket.read(3)
    @type_id = @socket.read(3)
    @len = 6
    if @type_id == 4
      read_value_packet
    else
      read_operator_packet
    end
    @len = @socket.cursor - start
  end

  def read_value_packet
    parts = []
    c = 1
    while c == 1
      c = @socket.read(1)
      v = @socket.read(4)
      parts << v
    end
    @value = 0
    sb = (parts.count-1) * 4
    parts.each do |p|
      @value += (p << sb)
      sb = sb - 4
    end
  end

  def read_operator_packet
    len_type = @socket.read(1)
    if len_type == 1
      nsub = @socket.read(11)
      nsub.times do 
        @sub_packets << Packet.new(@socket)
      end
    else
      sub_len = @socket.read(15)
      while sub_len > 0
        p = Packet.new(@socket)
        @sub_packets << p
        sub_len = sub_len - p.len        
      end
    end
    @sub_packets.each {|p| @len += p.len}
  end

  def version_sum
    return @version + @sub_packets.inject(0) {|s, p| s + p.version_sum }
  end

  def eval
    case @type_id
      when 4
        # literal value
        @value
      when 0
        # sum of all sub_packets
        @sub_packets.inject(0) {|s, p| s + p.eval }
      when 1
        # product of all sub_packets
        @sub_packets.inject(1) {|s, p| s * p.eval }
      when 2
        # minimum of all sub_packets
        @sub_packets.map{|p| p.eval}.min
      when 3
        # maximum of all sub_packets
        @sub_packets.map{|p| p.eval}.max
      when 5
        v0, v1 = @sub_packets[0..1].map{|p| p.eval}
        v0 > v1 ? 1 : 0
      when 6
        v0, v1 = @sub_packets[0..1].map{|p| p.eval}
        v0 < v1 ? 1 : 0
      when 7
        v0, v1 = @sub_packets[0..1].map{|p| p.eval}
        v0 == v1 ? 1 : 0
      else
        raise "Unexpected packet type"
    end
  end
end

class PacketReader < BaseAOC
  DAY=16
  def initialize(data)
    @socket = Socket.new(data)
    @packet = Packet.new(@socket)
  end

  def version_sum
    @packet.version_sum
  end

  def eval
    @packet.eval
  end
end


class PacketTest < MiniTest::Test
  def test_socket
    # dd = Packet.new("000102030405060708090A0B0C0D0E0F10FF")
    # assert_equal [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,255], dd.m

    s = Socket.new("EE00D40C823060")
    assert_equal "111", s.sub(0,3).to_s(2)
    assert_equal "101", s.sub(2,3).to_s(2)
    assert_equal "1100", s.sub(42,4).to_s(2)
    assert_equal "100000000011010", s.sub(6,15).to_s(2)
  end

  def test_packet
    s = Socket.new("D2FE28")
    p = Packet.new(s)
    assert_equal 6, p.version
    assert_equal 4, p.type_id
    assert_equal 2021, p.value

    s = Socket.new("38006F45291200")
    p = Packet.new(s)
    assert_equal 1, p.version
    assert_equal 6, p.type_id
    assert_equal 2, p.sub_packets.count
    assert_equal 10, p.sub_packets[0].value
    assert_equal 20, p.sub_packets[1].value

    s = Socket.new("EE00D40C823060")
    p = Packet.new(s)
    assert_equal 7, p.version
    assert_equal 3, p.type_id
    assert_equal 3, p.sub_packets.count
    assert_equal 1, p.sub_packets[0].value
    assert_equal 2, p.sub_packets[1].value
    assert_equal 3, p.sub_packets[2].value

    [
      "8A004A801A8002F478", 16,
      "620080001611562C8802118E34", 12,
      "C0015000016115A2E0802F182340", 23,
      "A0016C880162017C3686B18A3D4780", 31,
    ].each_slice(2) do |content, vs|    
      s = Socket.new(content)
      p = Packet.new(s)
      assert_equal vs, p.version_sum
    end

    [
      "C200B40A82", 3,
      "04005AC33890", 54,
      "880086C3E88112", 7,
      "CE00C43D881120", 9,
      "D8005AC2A8F0", 1,
      "F600BC2D8F", 0,
      "9C005AC2F8F0", 0,
      "9C0141080250320F1802104A08", 1,
    ].each_slice(2) do |content, ev|    
      s = Socket.new(content)
      p = Packet.new(s)
      assert_equal ev, p.eval
    end

  end

  def test_packetreader
    [
      "8A004A801A8002F478", 16,
      "620080001611562C8802118E34", 12,
      "C0015000016115A2E0802F182340", 23,
      "A0016C880162017C3686B18A3D4780", 31,
    ].each_slice(2) do |content, vs|    
      pr = PacketReader.new(content)
      assert_equal vs, pr.version_sum
    end

    [
      "C200B40A82", 3,
      "04005AC33890", 54,
      "880086C3E88112", 7,
      "CE00C43D881120", 9,
      "D8005AC2A8F0", 1,
      "F600BC2D8F", 0,
      "9C005AC2F8F0", 0,
      "9C0141080250320F1802104A08", 1,
    ].each_slice(2) do |content, ev|    
      pr = PacketReader.new(content)
      assert_equal ev, pr.eval
    end
  end
end


if MiniTest.run
  puts "Tests Passed!"

  pr = PacketReader.from_data
  vs = pr.version_sum
  puts "Total version sum: #{vs}"

  vv = pr.eval
  puts "The packet evaluate to #{vv}"
end
