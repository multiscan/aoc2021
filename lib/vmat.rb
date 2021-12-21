# Indexes management for the virtual matrix 
class VMat
  # n0: dimensions of the base matrix
  # nb: number of repetitions of the base matrix 
  def initialize(n0i, n0j, nbi, nbj)
    @n0i = n0i
    @n0j = n0j
    @nbi = nbi
    @nbj = nbj

    @n0k = @n0i * @n0j
    @ni = @nbi * @n0i
    @nj = @nbj * @n0j
    @nk = @ni * @nj
  end

  def count
    @nk
  end

  def k(i,j)
    return nil if (i<0 || i>=@ni || j<0 || j>=@nj)
    (j % @n0j) * @n0i + (i % @n0i) + ((j / @n0j) * @nbi + (i / @n0i)) * @n0k
  end

  def i(k)
    # (k % @n0k) % @n0i + ((k / @n0k) % @nbi) * @n0i
    k % @n0i + ((k / @n0k) % @nbi) * @n0i
  end

  def j(k)
    (k % @n0k) / @n0i + ((k / @n0k) / @nbi) * @n0j
  end

  def bi(k)    
    (k / @n0k) % @nbi
  end

  def bj(k)
    (k / @n0k) / @nbi
  end

  def ij(k)
    [i(k), j(k)]
  end

  def relative(l, v)
    v.map{|di,dj| k(i(l)+di, j(l)+dj)}.compact
  end

  def cross(k)
    relative k, [[-1,0], [1,0], [0,-1], [0,1]]
  end

  def surround(k)
    relative k, [[-1,-1], [0,-1], [1,-1], [-1,0], [1,0], [-1,1], [0,1], [1,1]]
  end
end

#  0  1  2  3    4  5  6  7    8  9 10 11
# 
#  0  1  2  3   12 13 14 15   24 25 26 27   0
#  4  5  6  7   16 17 18 19   28 29 30 31   1
#  8  9 10 11   20 21 22 23   32 33 34 35   2
# 
# 36 37 38 39   48 49 50 51   60 61 62 63   3
# 49 41 42 43   52 53 54 55   64 65 66 67   4
# 44 45 46 47   56 57 58 59   68 69 70 71   5
#
# Only the values of the first block are stored as the ramaining can be computed. 
# n0i, n0j = sizes of the first block
# i0, j0   = coordinates within the origin block: 0 <= i0 < n0i ; 0 <= j0 < n0j ; i0 = k0 % n0i ; j0 = k0 / n0i
# n0k      = 1d size of the first block n0k = n0i * n0j
# k0       = 1d index within the original block: k0 = j0 * n0i + i0 = k % n0k
# nbi, nbj = number of h/v repetitions
# nbk      = total number of number of blocks nbk = nbi * nbj 
# bk       = block index (0<=bk<nbk) bk = k / n0k = bj * nbi + bi
# bi,bj    = coord of block: bi = bk % nbi ; bj = bk / nbi
# ni, nj   = sizes of the full virtual matrix ni = nbi * n0i ; nj = nbj * n0j
# i, j     = coordinates within the full virtual matrix: 0 <= i < ni ; 0 <= j < nj
# nk       = 1d size of the full virtual matrix: nk = ni * nj
# k        = 1d index of the full virtual matrix

# (i,j) -> k
#   bi = i / n0i ; bj = j / n0j ; bk = bj * nbi + bi
#   i0 = i % n0i ; j0 = j % n0j; k0 = j0 * n0i + i0; 
#   k = k0 + bk * n0k

#   k = (j % n0j) * n0i + (i % n0i) + ((j / n0j) * nbi + (i / n0i)) * n0k

# k -> (i,j)
#   k0 = k % n0k ; i0 = k0 % n0i ; j0 = k0 / n0i
#   bk = k / n0k ; bi = bk % nbi ; bj = bk / nbi
#   i = i0 + bi * n0i ; j = j0 + bj * n0j

#   i = (k % n0k) % n0i + ((k / n0k) % nbi) * n0i
#   j = (k % n0k) / n0i + ((k / n0k) / nbi) * n0j