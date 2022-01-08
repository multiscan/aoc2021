struct Param {
    a: i64,
    b: i64,
    c: i64
}

// static PARAMS = [
static PARAMS: [Param; 14] = [
  Param {a:  1, b: 12, c:  4},
  Param {a:  1, b: 11, c: 10},
  Param {a:  1, b: 14, c: 12},
  Param {a: 26, b: -6, c: 14},
  Param {a:  1, b: 15, c:  6},
  Param {a:  1, b: 12, c: 16},
  Param {a: 26, b: -9, c:  1},
  Param {a:  1, b: 14, c:  7},
  Param {a:  1, b: 14, c:  8},
  Param {a: 26, b: -5, c: 11},
  Param {a: 26, b: -9, c:  8},
  Param {a: 26, b: -5, c:  3},
  Param {a: 26, b: -2, c:  1},
  Param {a: 26, b: -7, c:  8},
];

static LOOPDOWN : [i64; 9] = [9,8,7,6,5,4,3,2,1];
static LOOPUP : [i64; 9] = [1,2,3,4,5,6,7,8,9];

// full search
// static STARTDOWN : [usize; 14] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
// static STARTUP : [usize; 14]   = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

// Found the numbers with ruby => start closer to result just for testing
// 91398299697996
// 41171183141291
static STARTDOWN : [usize; 14] = [9-9, 9-1, 9-3, 9-9, 9-8, 9-2, 9-9, 9-9, 9-6, 0, 0, 0, 0, 0];
static STARTUP : [usize; 14]   = [4-1, 1-1, 1-1, 7-1, 1-1, 1-1, 8-1, 3-1, 1-1, 0, 0, 0, 0, 0];

fn zp(i: usize, w: i64, z0: i64) -> i64 {
    let x = z0 % 26 + PARAMS[i].b;
    let mut z = z0 / PARAMS[i].a;
    if x != w {
        z = z * 26 + w + PARAMS[i].c;
    }
    if i < 3 {
        println!("w{} = {} -> {}", i, w, z);
    }
    return z;
}

fn wteni(i: usize, w: i64) -> i64 {
    let ten = 10;
    let ii: u32 = i as u32;
    let teni = i64::pow(ten, 13 - ii);
    return w * teni;
}

fn solve_iter(i: usize, z0: i64, myiter: [i64; 9], mystart: [usize; 14]) -> i64 {
    let mut d : i64;
    let mut j: usize;
    if PARAMS[i].a == 1 {
        j = mystart[i];
        while j < 9 {
            let w = myiter[j];
            j = j + 1;
            let z = zp(i, w, z0);
            d = solve_iter(i+1, z, myiter, mystart);
            if d > 0 {
                return d + wteni(i, w);
            }
        }
    } else {
        let w = z0 % 26 + PARAMS[i].b;
        if 0 < w && w < 10 {
            let z = zp(i, w, z0);
            if i==13 {
                if z == 0 {
                    return w;
                }
            } else {
                d = solve_iter(i+1, z, myiter, mystart);
                if d > 0 {
                    return d + wteni(i, w);
                }
            }
        } else {
            j = mystart[i];
            if i==13 {
                while j < 9 {
                    let w = myiter[j];
                    j = j + 1;
                    let z = zp(i, w, z0);
                    if z == 0 {
                        return w;
                    }
                }
            } else {
                while j < 9 {
                    let w = myiter[j];
                    j = j + 1;
                    let z = zp(i, w, z0);
                    d = solve_iter(i+1, z, myiter, mystart);
                    if d > 0 {
                        return d + wteni(i, w);
                    }
                }
            }
        }
    }
    return 0;
}

fn main() {
    let r = solve_iter(0,0,LOOPDOWN,STARTDOWN);
    println!("{}", r);
    let r = solve_iter(0,0,LOOPUP,STARTUP);
    println!("{}", r);
}
