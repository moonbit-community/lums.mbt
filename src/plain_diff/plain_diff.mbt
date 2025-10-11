/// Basic algorithm described by Eugene W.Myers in: "An O(ND) Difference Algorithm and Its Variations"

///|
/// A partition is the midpoint of the shortest edit script for a specified portion of two
/// vectors.
///
/// `xmid`, `ymid` is the midpoint discovered. The diagonal number `xmid - ymid` equals the
/// number of inserted elements minus the number of deleted elements (counting only
/// elements before the midpoint).
///
/// `lo_minimal` is true iff the minimal edit script for the left half of the partition is
/// known; similarly for `hi_minimal`.
#valtype
priv struct Partition {
  xmid : Int
  ymid : Int
  lo_minimal : Bool
  hi_minimal : Bool
}

///|
/// Find the midpoint of the shortest edit script for a specified portion of the two
/// vectors.
///
/// Scan from the beginnings of the vectors, and simultaneously from the ends, doing a
/// breadth-first search through the space of edit-sequence. When the two searches meet, we
/// have found the midpoint of the shortest edit sequence.
///
/// If `find_minimal` is true, find the minimal edit script regardless of expense.
/// Otherwise, if the search is too expensive, use heuristics to stop the search and report
/// a suboptimal answer.
/// 
/// This function assumes that the first elements of the specified portions of the two
/// vectors do not match, and likewise that the last elements do not match. The caller must
/// trim matching elements from the beginning and end of the portions it is going to
/// specify.
///
/// If we return the "wrong" partitions, the worst this can do is cause suboptimal diff
/// output. It cannot cause incorrect diff output.
fn[T] diag(
  fd~ : Array[Int],
  bd~ : Array[Int],
  sh~ : Int,
  xv~ : (Int) -> T,
  yv~ : (Int) -> T,
  xoff~ : Int,
  xlim~ : Int,
  yoff~ : Int,
  ylim~ : Int,
  too_expensive~ : Int,
  find_minimal~ : Bool,
) -> Partition {
  let dmin = xoff - ylim // minimum valid diagonal
  let dmax = xlim - yoff // maximum valid diagonal
  let fmid = xoff - yoff // center diagonal of forward search
  let bmid = xlim - ylim // center diagonal of backward search
  // southeast corner is on an odd diagonal w.r.t the northwest
  let odd = ((fmid - bmid) & 1) != 0
  // `sh` is an offset that lets us use indices in [-(m+1), n+1]
  fd[sh + fmid] = xoff
  bd[sh + bmid] = xlim

  // Main loop with cost counter
  loop (1, fmid, fmid, bmid, bmid) {
    (c, fmin, fmax, bmin, bmax) => {
      // Extend the forward search by one edit step in each diagonal
      let fmin = if fmin > dmin {
        fd[sh + fmin - 2] = -1
        fmin - 1
      } else {
        fmin + 1
      }
      let fmax = if fmax < dmax {
        fd[sh + fmax + 2] = -1
        fmax + 1
      } else {
        fmax - 1
      }

      // Process forward diagonals - check for early return
      let mut forward_result : Partition? = None
      let mut d = fmax
      while d >= fmin {
        let tlo = fd[sh + d - 1]
        let thi = fd[sh + d + 1]
        let x = if tlo >= thi { tlo + 1 } else { thi }

        // Find matching sequences
        let mut x_cur = x
        let mut y_cur = x_cur - d
        while x_cur < xlim &&
              y_cur < ylim &&
              physical_equal(xv(x_cur), yv(y_cur)) {
          x_cur += 1
          y_cur += 1
        }
        fd[sh + d] = x_cur
        if odd && bmin <= d && d <= bmax && bd[sh + d] <= fd[sh + d] {
          forward_result = Some({
            xmid: x_cur,
            ymid: y_cur,
            lo_minimal: true,
            hi_minimal: true,
          })
          break
        }
        d -= 2
      }
      match forward_result {
        Some(result) => break result
        None => ()
      }

      // Similarly extend the backward search
      let bmin = if bmin > dmin {
        bd[sh + bmin - 2] = @int.max_value
        bmin - 1
      } else {
        bmin + 1
      }
      let bmax = if bmax < dmax {
        bd[sh + bmax + 2] = @int.max_value
        bmax + 1
      } else {
        bmax - 1
      }

      // Process backward diagonals - check for early return
      let mut backward_result : Partition? = None
      let mut d = bmax
      while d >= bmin {
        let tlo = bd[sh + d - 1]
        let thi = bd[sh + d + 1]
        let x = if tlo < thi { tlo } else { thi - 1 }

        // Find matching sequences backwards
        let mut x_cur = x
        let mut y_cur = x_cur - d
        while x_cur > xoff &&
              y_cur > yoff &&
              physical_equal(xv(x_cur - 1), yv(y_cur - 1)) {
          x_cur -= 1
          y_cur -= 1
        }
        bd[sh + d] = x_cur
        if not(odd) && fmin <= d && d <= fmax && bd[sh + d] <= fd[sh + d] {
          backward_result = Some({
            xmid: x_cur,
            ymid: y_cur,
            lo_minimal: true,
            hi_minimal: true,
          })
          break
        }
        d -= 2
      }
      match backward_result {
        Some(result) => break result
        None => ()
      }

      // Heuristic: if we've gone well beyond the call of duty, give up and report halfway between our best results so far.
      if not(find_minimal) && c >= too_expensive {
        // Find forward diagonal that maximizes x + y
        let mut fxybest = -1
        let mut fxbest = fmax
        let mut d = fmax
        while d >= fmin {
          let x = xlim.min(fd[sh + d])
          let y = x - d
          let (x, y) = if ylim < y { (ylim + d, ylim) } else { (x, y) }
          if fxybest < x + y {
            fxybest = x + y
            fxbest = x
          }
          d -= 2
        }

        // Find backward diagonal that minimizes x + y
        let mut bxybest = @int.max_value
        let mut bxbest = bmax
        let mut d = bmax
        while d >= bmin {
          let x = xoff.max(bd[sh + d])
          let y = x - d
          let (x, y) = if y < yoff { (yoff + d, yoff) } else { (x, y) }
          if x + y < bxybest {
            bxybest = x + y
            bxbest = x
          }
          d -= 2
        }
        if xlim + ylim - bxybest < fxybest - (xoff + yoff) {
          break {
            xmid: fxbest,
            ymid: fxybest - fxbest,
            lo_minimal: true,
            hi_minimal: false,
          }
        } else {
          break {
            xmid: bxbest,
            ymid: bxybest - bxbest,
            lo_minimal: false,
            hi_minimal: true,
          }
        }
      } else {
        continue (c + 1, fmin, fmax, bmin, bmax)
      }
    }
  }
}

///|
/// Main diff loop that computes the differences between two arrays
fn[T] diff_loop(
  cutoff : Int?,
  a : Array[T],
  ai : Array[Int],
  b : Array[T],
  bi : Array[Int],
  n : Int,
  m : Int,
) -> (Array[Bool], Array[Bool]) {
  let fd = Array::make(n + m + 3, 0)
  let bd = Array::make(n + m + 3, 0)
  let sh = m + 1
  let too_expensive = match cutoff {
    Some(c) => c
    None => {
      let diags = n + m + 3
      let mut result = 1
      let mut diags_cur = diags
      while diags_cur != 0 {
        diags_cur = diags_cur >> 2
        result = result << 1
      }
      result.max(4096)
    }
  }
  let xvec = fn(i) { a[ai[i]] }
  let yvec = fn(j) { b[bi[j]] }
  let chng1 = Array::make(a.length(), true)
  let chng2 = Array::make(b.length(), true)
  for i = 0; i < n; i = i + 1 {
    chng1[ai[i]] = false
  }
  for j = 0; j < m; j = j + 1 {
    chng2[bi[j]] = false
  }
  fn loop_recursive(
    xoff : Int,
    xlim : Int,
    yoff : Int,
    ylim : Int,
    find_minimal : Bool,
  ) -> Unit {
    // Skip matching prefix
    let mut xoff = xoff
    let mut yoff = yoff
    while xoff < xlim && yoff < ylim && physical_equal(xvec(xoff), yvec(yoff)) {
      xoff += 1
      yoff += 1
    }

    // Skip matching suffix
    let mut xlim = xlim
    let mut ylim = ylim
    while xlim > xoff &&
          ylim > yoff &&
          physical_equal(xvec(xlim - 1), yvec(ylim - 1)) {
      xlim -= 1
      ylim -= 1
    }
    if xoff == xlim {
      // Only insertions
      for y = yoff; y < ylim; y = y + 1 {
        chng2[bi[y]] = true
      }
    } else if yoff == ylim {
      // Only deletions
      for x = xoff; x < xlim; x = x + 1 {
        chng1[ai[x]] = true
      }
    } else {
      // Find partition and recurse
      let partition = diag(
        fd~,
        bd~,
        sh~,
        xv=xvec,
        yv=yvec,
        xoff~,
        xlim~,
        yoff~,
        ylim~,
        too_expensive~,
        find_minimal~,
      )
      loop_recursive(
        xoff,
        partition.xmid,
        yoff,
        partition.ymid,
        partition.lo_minimal,
      )
      loop_recursive(
        partition.xmid,
        xlim,
        partition.ymid,
        ylim,
        partition.hi_minimal,
      )
    }
  }

  loop_recursive(0, n, 0, m, false)
  (chng1, chng2)
}

///|
/// `make_indexer(a b)` returns an array of the indices of items of `a` which are also
/// present in `b`; this way, the main algorithm can skip items which, anyway, are
/// different. This improves the speed much. At the same time, this function updates the
/// items of `a` and `b` so that all equal items point to the same unique item.
/// 
/// All item comparisons in the main algorithm can therefore be done with `physical_equal` 
/// instead of `==`, which can improve speed much.
fn[T : Eq + Hash] make_indexer(a : Array[T], b : Array[T]) -> Array[Int] {
  let n = a.length()
  let htb : Map[T, T] = Map::new()

  // Update b array and populate hash table
  for i = 0; i < b.length(); i = i + 1 {
    match htb.get(b[i]) {
      Some(v) => b[i] = v
      None => htb[b[i]] = b[i]
    }
  }
  let ai = Array::make(n, 0)
  let mut k = 0

  // Find matching elements in a
  for i = 0; i < n; i = i + 1 {
    match htb.get(a[i]) {
      Some(v) => {
        a[i] = v
        ai[k] = i
        k += 1
      }
      None => ()
    }
  }

  // Return subarray with only valid indices
  let result = Array::make(k, 0)
  for i = 0; i < k; i = i + 1 {
    result[i] = ai[i]
  }
  result
}

///|
/// Main function that computes diff between two arrays
fn[T : Eq + Hash] diff(
  cutoff : Int?,
  a : Array[T],
  b : Array[T],
) -> (Array[Bool], Array[Bool]) {
  let ai = make_indexer(a, b)
  let bi = make_indexer(b, a)
  let n = ai.length()
  let m = bi.length()
  diff_loop(cutoff, a, ai, b, bi, n, m)
}

///|
/// `iter_matches(?cutoff, old~, new~, fn)` diffs the arrays `old~` and `new~` (as in /usr/bin/diff),
/// and calls `f` on each element of the longest common subsequence in
/// increasing order. The arguments of `f` are the indices in `old~` and `new~`, respectively,
/// of that element.
///
/// The `cutoff` is an upper bound on the minimum edit distance between `old~` and `new~`. When
/// `cutoff` is exceeded, `iter_matches` returns a correct, but not necessarily minimal
/// diff. It defaults to about `sqrt(a.length() + b.length())`.
pub fn[T : Eq + Hash] iter_matches(
  cutoff? : Int,
  f : (Int, Int) -> Unit,
  old~ : Array[T],
  new~ : Array[T],
) -> Unit {
  let (d1, d2) = diff(cutoff, old, new)
  fn aux(i1 : Int, i2 : Int) -> Unit {
    if i1 >= d1.length() || i2 >= d2.length() {
      ()
    } else if not(d1[i1]) {
      if not(d2[i2]) {
        f(i1, i2)
        aux(i1 + 1, i2 + 1)
      } else {
        aux(i1, i2 + 1)
      }
    } else if not(d2[i2]) {
      aux(i1 + 1, i2)
    } else {
      aux(i1 + 1, i2 + 1)
    }
  }

  aux(0, 0)
}
