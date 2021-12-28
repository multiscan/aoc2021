class Vec
  def initialize(v)
    @v = v
  end
  def v(i)
    @v[i]
  end
  def +(other)
    Vec.new([v(0)+other.v(0), v(1)+other.v(1), v(2)+other.v(2)])
  end
  def -(other)
    Vec.new([v(0)-other.v(0), v(1)-other.v(1), v(2)-other.v(2)])
  end
  def modulo
    @v[0]*@v[0] + @v[1]*@v[1] + @v[2]*@v[2]
  end
  def join(sep)
    @v.join(sep)
  end
  def inspect
    "(#{@v.join(',')})"
  end
  def neg
    return Vec.new([-@v[0], -@v[1], -@v[2]])
  end
  def ==(other)
    v(0) == other.v(0) && v(1) == other.v(1) && v(2)+other.v(2)
  end
end

class RotMat

  # 1  0  0
  # 0  1  0
  # 0  0  1
  def self.identity
    return RotMat.new([[1,0,0], [0,1,0], [0,0,1]])
  end

  # 1  0  0
  # 0  0 -1
  # 0  1  0
  def self.rx
    return RotMat.new([[1,0,0], [0, 0,-1], [0, 1, 0]])
  end
  #  0  0  1
  #  0  1  0
  # -1  0  0
  def self.ry
    return RotMat.new([[0,0,1], [0,1,0], [-1,0,0]])
  end

  #  0 -1  0
  #  1  0  0
  #  0  0  1
  def self.rz
    return RotMat.new([[0,-1,0], [1,0,0], [0,0,1]])
  end

  def eql?(other)
    puts "=="
    @m[0] == other.m[0] && @m[1] == other.m[1] && @m[2] == other.m[2]
  end

  # find RotMat m | v1 = m * v2
  def self.between(v1, v2)
    self.all.each do |m|
      v = m * v2
      return m if v == v1
    end
    return nil
  end

  # find RotMat m | v1 = m * v2
  def self.between_debug(v1, v2)
    self.all.each do |m|
      p m
      v = m * v1
      puts "m * #{v1.inspect} = #{v.inspect}    <->   #{v2.inspect}"
      return m if v == v2
    end
    return nil
  end

  def self.all
    @all ||= begin
      rr = [
        RotMat.new([[ 0,  0,  1],    [ 0,  1,  0],    [-1,  0,  0]]),
        RotMat.new([[ 0,  0,  1],    [ 0, -1,  0],    [ 1,  0,  0]]),
        RotMat.new([[ 0,  0,  1],    [ 1,  0,  0],    [ 0,  1,  0]]),
        RotMat.new([[ 0,  0,  1],    [-1,  0,  0],    [ 0, -1,  0]]),
        RotMat.new([[ 0,  0, -1],    [ 0,  1,  0],    [ 1,  0,  0]]),
        RotMat.new([[ 0,  0, -1],    [ 0, -1,  0],    [-1,  0,  0]]),
        RotMat.new([[ 0,  0, -1],    [ 1,  0,  0],    [ 0, -1,  0]]),
        RotMat.new([[ 0,  0, -1],    [-1,  0,  0],    [ 0,  1,  0]]),
        RotMat.new([[ 0,  1,  0],    [ 0,  0,  1],    [ 1,  0,  0]]),
        RotMat.new([[ 0,  1,  0],    [ 0,  0, -1],    [-1,  0,  0]]),
        RotMat.new([[ 0,  1,  0],    [ 1,  0,  0],    [ 0,  0, -1]]),
        RotMat.new([[ 0,  1,  0],    [-1,  0,  0],    [ 0,  0,  1]]),
        RotMat.new([[ 0, -1,  0],    [ 0,  0,  1],    [-1,  0,  0]]),
        RotMat.new([[ 0, -1,  0],    [ 0,  0, -1],    [ 1,  0,  0]]),
        RotMat.new([[ 0, -1,  0],    [ 1,  0,  0],    [ 0,  0,  1]]),
        RotMat.new([[ 0, -1,  0],    [-1,  0,  0],    [ 0,  0, -1]]),
        RotMat.new([[ 1,  0,  0],    [ 0,  0,  1],    [ 0, -1,  0]]),
        RotMat.new([[ 1,  0,  0],    [ 0,  0, -1],    [ 0,  1,  0]]),
        RotMat.new([[ 1,  0,  0],    [ 0,  1,  0],    [ 0,  0,  1]]),
        RotMat.new([[ 1,  0,  0],    [ 0, -1,  0],    [ 0,  0, -1]]),
        RotMat.new([[-1,  0,  0],    [ 0,  0,  1],    [ 0,  1,  0]]),
        RotMat.new([[-1,  0,  0],    [ 0,  0, -1],    [ 0, -1,  0]]),
        RotMat.new([[-1,  0,  0],    [ 0,  1,  0],    [ 0,  0, -1]]),
        RotMat.new([[-1,  0,  0],    [ 0, -1,  0],    [ 0,  0,  1]]),
      ]
      rr
    end
  end

  # def self.all
  #   @all ||= begin
  #     rr = []
  #     br = [self.rx, self.ry, self.rz]
  #     pp = [0,0,0,1,1,1,2,2,2].permutation
  #     [5,4,3,2,1,0].each do |c|
  #       pp.map{|p| p[..c]}.uniq.each do |p|
  #         r  = br[p.shift]
  #         while ir=p.shift
  #           r = r * br[ir]
  #         end
  #         rr << r
  #       end
  #     end
  #     rr.uniq
  #   end
  # end

  # def self.all
  #   @all ||= begin
  #     r = []
  #     rx = self.rx ; r2x = rx * rx ; r3x = r2x * rx
  #     ry = self.ry ; r2y = ry * ry ; r3y = r2y * ry
  #     rz = self.rz ; r2z = rz * rz ; r3z = r2z * rz
  #     r << self.identity  #  0
  #     r << rx             #  1
  #     r << ry             #  2
  #     r << rz             #  3
  #     r << r2x            #  4
  #     r << r2y            #  5
  #     r << r2z            #  6
  #     r << r3x            #  7
  #     r << r3y            #  8
  #     r << r3z            #  9
  #     r << rx * ry        # 10
  #     r << rx * r2y       # 11
  #     r << rx * r3y       # 12
  #     r << r2x * ry       # 13
  #     r << r2x * r2z      # 14
  #     r << r2x * r3y      # 15
  #     r << r3x * ry       # 16
  #     r << r3x * r2y      # 17
  #     r << r3x * r3y      # 18
  #     r << rx * rz        # 19
  #     r << rx * r3z       # 20
  #     r << r2x * rz       # 21
  #     r << r2x * r3z      # 22
  #     r << r3x * rz       # 23
  #     r << r3x * r3z      # 24
  #     r
  #   end
  # end

  def initialize(m)
    @m = m
  end
  #     +----- row index
  #     | +--- col index
  #     | |
  def m(i,j)
    @m[i][j]
  end

  def inspect
    sprintf("\n%2d %2d %2d\n%2d %2d %2d\n%2d %2d %2d\n", m(0,0), m(0,1), m(0,2), m(1,0), m(1,1), m(1,2), m(2,0), m(2,1), m(2,2))
  end

  def to_s
    sprintf("%2d %2d %2d    %2d %2d %2d    %2d %2d %2d", m(0,0), m(0,1), m(0,2), m(1,0), m(1,1), m(1,2), m(2,0), m(2,1), m(2,2))
  end


  def *(other)
    if other.class == RotMat
      p = [
        [m(0,0)*other.m(0,0)+m(0,1)*other.m(1,0)+m(0,2)*other.m(2,0), m(0,0)*other.m(0,1)+m(0,1)*other.m(1,1)+m(0,2)*other.m(2,1), m(0,0)*other.m(0,2)+m(0,1)*other.m(1,2)+m(0,2)*other.m(2,2)],
        [m(1,0)*other.m(0,0)+m(1,1)*other.m(1,0)+m(1,2)*other.m(2,0), m(1,0)*other.m(0,1)+m(1,1)*other.m(1,1)+m(1,2)*other.m(2,1), m(1,0)*other.m(0,2)+m(1,1)*other.m(1,2)+m(1,2)*other.m(2,2)],
        [m(2,0)*other.m(0,0)+m(2,1)*other.m(1,0)+m(2,2)*other.m(2,0), m(2,0)*other.m(0,1)+m(2,1)*other.m(1,1)+m(2,2)*other.m(2,1), m(2,0)*other.m(0,2)+m(2,1)*other.m(1,2)+m(2,2)*other.m(2,2)],
      ]
      return RotMat.new(p)
    elsif other.class == Vec
      v = [
        m(0,0)*other.v(0) + m(0,1) * other.v(1) + m(0,2) * other.v(2),
        m(1,0)*other.v(0) + m(1,1) * other.v(1) + m(1,2) * other.v(2),
        m(2,0)*other.v(0) + m(2,1) * other.v(1) + m(2,2) * other.v(2)
      ]
      return Vec.new(v)
    end
  end
end



# m = RotMat.new([[0,  1,  0],[-1,  0,  0], [0,  0,  1]])
# vb = Vec.new([-3,-1,0])
#
# aaa = vb.neg
# puts "vb=#{vb.inspect}     -vb = #{aaa.inspect}"
#
# p m
# puts "vb=#{vb.inspect}"
# mvb = m * vb
# puts "mvb=#{mvb.inspect}"
#
# va = Vec.new([-1,3,0])
# mm = RotMat.between(va,vb)
#
# puts "between: #{mm.inspect}"

# RotMat.rx.inspect
# RotMat.ry.inspect
# RotMat.rz.inspect
# rx = RotMat.rx
# p rx
# r2x = rx * rx
# p r2x
# RotMat.all.each {|r| p r}

# m = RotMat.rz
# v1= Vec.new([12, 45, 23])
# v2 = m * v1
# n = RotMat.between(v1, v2)
# p m
# p n
