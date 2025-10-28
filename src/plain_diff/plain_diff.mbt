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
  xmid : Int // position of midpoint in sequence A
  ymid : Int // position of midpoint in sequence B
  lo_minimal : Bool // whether left half is optimal
  hi_minimal : Bool // whether right half is optimal
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
///
/// Parameter mapping to Myers algorithm concepts:
/// - fd~: forward search diagonal array, fd[k] stores the farthest x coordinate reachable on diagonal k
/// - bd~: backward search diagonal array, bd[k] stores the nearest x coordinate reachable on diagonal k  
/// - sh~: array index offset, supporting negative diagonal indices (since k can be negative)
/// - xv~, yv~: functions to access elements of sequences A and B, supporting indirect access
/// - xoff~, xlim~: search range for sequence A [xoff, xlim)
/// - yoff~, ylim~: search range for sequence B [yoff, ylim)  
/// - too_expensive~: computation cost upper limit, preventing algorithm from running too long in difficult cases
/// - find_minimal~: whether to force finding minimal edit script (regardless of computation cost)
/// 
fn[T] diag(
  fd~ : FixedArray[Int], // forward search diagonal array - stores farthest reachable point on each diagonal
  bd~ : FixedArray[Int], // backward search diagonal array - stores nearest reachable point on each diagonal
  sh~ : Int, // array index offset - enables arrays to support negative indices
  xv~ : (Int) -> T, // access function for sequence A - supports indirect access and index remapping
  yv~ : (Int) -> T, // access function for sequence B - supports indirect access and index remapping
  xoff~ : Int, // starting position of sequence A - defines left boundary of search window
  xlim~ : Int, // ending position of sequence A - defines right boundary of search window
  yoff~ : Int, // starting position of sequence B - defines upper boundary of search window  
  ylim~ : Int, // ending position of sequence B - defines lower boundary of search window
  too_expensive~ : Int, // computation cost threshold - use heuristic algorithm when exceeded
  find_minimal~ : Bool, // optimality flag - whether optimal solution must be found
) -> Partition {
  // Calculate range of valid diagonals
  // In edit graph, diagonal k = x - y, valid range determined by search window
  let dmin = xoff - ylim // minimum valid diagonal - corresponds to maximum insertions
  let dmax = xlim - yoff // maximum valid diagonal - corresponds to maximum deletions
  let fmid = xoff - yoff // center diagonal for forward search - diagonal corresponding to starting point
  let bmid = xlim - ylim // center diagonal for backward search - diagonal corresponding to end point

  // Determine parity: whether southeast corner is on odd diagonal relative to northwest corner
  // This determines when forward and backward searches meet (they meet in same step only when parity differs)
  let odd = ((fmid - bmid) & 1) != 0

  // Initialize search starting points
  // sh is offset, enabling us to use indices in range [-(m+1), n+1]
  fd[sh + fmid] = xoff // forward search starts from (xoff, yoff)
  bd[sh + bmid] = xlim // backward search starts from (xlim, ylim)

  // Main loop: alternate forward and backward search, increasing edit distance by one each time
  // c: current edit distance (search depth)
  // fmin, fmax: diagonal range for forward search
  // bmin, bmax: diagonal range for backward search
  loop (1, fmid, fmid, bmid, bmid) {
    (c, fmin, fmax, bmin, bmax) => {
      // Extend diagonal range for forward search
      // Each iteration expands search range as edit distance increases by 1
      let fmin = if fmin > dmin {
        fd[sh + fmin - 2] = -1 // mark unused diagonal
        fmin - 1 // extend to next diagonal
      } else {
        fmin + 1 // boundary constraint
      }
      let fmax = if fmax < dmax {
        fd[sh + fmax + 2] = -1 // mark unused diagonal  
        fmax + 1 // extend to previous diagonal
      } else {
        fmax - 1 // boundary constraint
      }

      // Process all diagonals for forward search
      let mut forward_result : Partition? = None
      let mut d = fmax
      while d >= fmin {
        // Get farthest reachable points on adjacent diagonals
        // tlo: x coordinate on lower-left diagonal (d-1), position after deletion
        // thi: x coordinate on upper-right diagonal (d+1), position after insertion
        let tlo = fd[sh + d - 1]
        let thi = fd[sh + d + 1]

        // Choose better path: transfer from diagonal that reaches farther x coordinate
        // This embodies Myers algorithm's greedy strategy: prioritize paths that go farther
        let x = if tlo >= thi { tlo + 1 } else { thi }

        // Search for matching sequence along diagonal (Snake)
        // This is key optimization of Myers algorithm: freely extend matching elements
        let mut x_cur = x
        let mut y_cur = x_cur - d // from diagonal relation k = x - y, we get y = x - k
        while x_cur < xlim &&
              y_cur < ylim &&
              physical_equal(xv(x_cur), yv(y_cur)) {
          x_cur += 1
          y_cur += 1
        }

        // Update farthest reachable point on current diagonal
        fd[sh + d] = x_cur

        // Check if meeting with backward search
        // Meeting conditions: parity matches && diagonal is in backward search range && forward/backward search points overlap
        if odd && bmin <= d && d <= bmax && bd[sh + d] <= fd[sh + d] {
          forward_result = Some({
            xmid: x_cur,
            ymid: y_cur,
            lo_minimal: true, // forward path is optimal
            hi_minimal: true, // backward path is also optimal
          })
          break // found meeting point, exit early
        }
        d -= 2 // Myers algorithm characteristic: only check diagonals with same parity
      }

      // If forward search found solution, return directly
      match forward_result {
        Some(result) => break result
        None => ()
      }

      // Similarly extend diagonal range for backward search
      let bmin = if bmin > dmin {
        bd[sh + bmin - 2] = @int.max_value // mark unused diagonal as max value
        bmin - 1
      } else {
        bmin + 1
      }
      let bmax = if bmax < dmax {
        bd[sh + bmax + 2] = @int.max_value // mark unused diagonal as max value
        bmax + 1
      } else {
        bmax - 1
      }

      // Process all diagonals for backward search
      let mut backward_result : Partition? = None
      let mut d = bmax
      while d >= bmin {
        // Get nearest reachable points on adjacent diagonals (backward search in reverse direction)
        let tlo = bd[sh + d - 1]
        let thi = bd[sh + d + 1]

        // Backward search selection strategy: choose point with smaller x coordinate (closer to start)
        let x = if tlo < thi { tlo } else { thi - 1 }

        // Search backward for matching sequence (reverse Snake)
        let mut x_cur = x
        let mut y_cur = x_cur - d
        while x_cur > xoff &&
              y_cur > yoff &&
              physical_equal(xv(x_cur - 1), yv(y_cur - 1)) {
          x_cur -= 1
          y_cur -= 1
        }

        // Update nearest reachable point on current diagonal
        bd[sh + d] = x_cur

        // Check if meeting with forward search (meeting condition for even case)
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

      // If backward search found solution, return directly
      match backward_result {
        Some(result) => break result
        None => ()
      }

      // Heuristic handling: if computation cost too high, abandon finding optimal solution
      // This is important mechanism for Myers algorithm to handle difficult cases
      if not(find_minimal) && c >= too_expensive {
        // Find diagonal in forward search that maximizes x + y
        // This indicates processing maximum number of elements overall
        let mut fxybest = -1
        let mut fxbest = fmax
        let mut d = fmax
        while d >= fmin {
          let x = xlim.min(fd[sh + d]) // limit to valid range
          let y = x - d
          let (x, y) = if ylim < y { (ylim + d, ylim) } else { (x, y) }
          if fxybest < x + y {
            fxybest = x + y
            fxbest = x
          }
          d -= 2
        }

        // Find diagonal in backward search that minimizes x + y
        // This indicates reasonable partition point closest to start
        let mut bxybest = @int.max_value
        let mut bxbest = bmax
        let mut d = bmax
        while d >= bmin {
          let x = xoff.max(bd[sh + d]) // limit to valid range
          let y = x - d
          let (x, y) = if y < yoff { (yoff + d, yoff) } else { (x, y) }
          if x + y < bxybest {
            bxybest = x + y
            bxbest = x
          }
          d -= 2
        }

        // Choose better heuristic partition point
        // Compare "quality" of forward and backward, choose side that processes more elements
        if xlim + ylim - bxybest < fxybest - (xoff + yoff) {
          break {
            xmid: fxbest,
            ymid: fxybest - fxbest,
            lo_minimal: true,
            hi_minimal: false, // right half is not optimal
          }
        } else {
          break {
            xmid: bxbest,
            ymid: bxybest - bxbest,
            lo_minimal: false, // left half is not optimal
            hi_minimal: true,
          }
        }
      } else {
        // Continue next round of search, edit distance increases by 1
        continue (c + 1, fmin, fmax, bmin, bmax)
      }
    }
  }
}

///|
/// Main diff loop that computes the differences between two arrays
fn[T] diff_loop(
  cutoff : Int?, // computation cost threshold
  a : MutArrayView[T], // original array A
  ai : Array[Int], // indices of A elements that exist in B
  b : MutArrayView[T], // original array B  
  bi : Array[Int], // indices of B elements that exist in A
  n : Int, // number of valid indices (A)
  m : Int, // number of valid indices (B)
) -> (Array[Bool], Array[Bool]) {
  // Allocate working arrays for Myers algorithm
  // Array size is n+m+3, sufficient to contain all possible diagonals
  let fd = FixedArray::make(n + m + 3, 0) // forward search array
  let bd = FixedArray::make(n + m + 3, 0) // backward search array
  let sh = m + 1 // index offset, supporting negative diagonals

  // Determine computation cost threshold
  let too_expensive = match cutoff {
    Some(c) => c
    None => {
      // Default strategy: calculate reasonable threshold based on problem size
      // Use bit operations to quickly compute approximate square root
      let diags = n + m + 3
      let mut result = 1
      let mut diags_cur = diags
      while diags_cur != 0 {
        diags_cur = diags_cur >> 2
        result = result << 1
      }
      result.max(4096) // at least 4096, ensuring reasonable performance
    }
  }

  // Create element access functions - supporting indirect access
  // This allows algorithm to process only elements that exist in both arrays
  let xvec = fn(i) { a[ai[i]] } // access A elements through index array
  let yvec = fn(j) { b[bi[j]] } // access B elements through index array

  // Initialize change marker arrays
  // true indicates element is deleted/inserted, false indicates element unchanged
  let chng1 = Array::make(a.length(), true) // change markers for A
  let chng2 = Array::make(b.length(), true) // change markers for B

  // Preset common elements as unchanged
  for i = 0; i < n; i = i + 1 {
    chng1[ai[i]] = false // A elements that also exist in B marked as unchanged
  }
  for j = 0; j < m; j = j + 1 {
    chng2[bi[j]] = false // B elements that also exist in A marked as unchanged  
  }

  // Recursive function: implement divide-and-conquer strategy
  // Recursively apply Myers algorithm to each subregion
  fn loop_recursive(
    xoff : Int, // starting position of current A processing
    xlim : Int, // ending position of current A processing  
    yoff : Int, // starting position of current B processing
    ylim : Int, // ending position of current B processing
    find_minimal : Bool, // whether optimal solution needs to be found
  ) -> Unit {
    // Optimization: skip matching prefix
    // This is important optimization of Myers algorithm, reducing data to process
    let mut xoff = xoff
    let mut yoff = yoff
    while xoff < xlim && yoff < ylim && physical_equal(xvec(xoff), yvec(yoff)) {
      xoff += 1
      yoff += 1
    }

    // Optimization: skip matching suffix  
    let mut xlim = xlim
    let mut ylim = ylim
    while xlim > xoff &&
          ylim > yoff &&
          physical_equal(xvec(xlim - 1), yvec(ylim - 1)) {
      xlim -= 1
      ylim -= 1
    }

    // Handle boundary cases
    if xoff == xlim {
      // Only insertions: A part exhausted, remaining B part all insertions
      for y = yoff; y < ylim; y = y + 1 {
        chng2[bi[y]] = true
      }
    } else if yoff == ylim {
      // Only deletions: B part exhausted, remaining A part all deletions
      for x = xoff; x < xlim; x = x + 1 {
        chng1[ai[x]] = true
      }
    } else {
      // General case: need to find partition point and recursively process
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

      // Recursively process left half (before partition point)
      loop_recursive(
        xoff,
        partition.xmid,
        yoff,
        partition.ymid,
        partition.lo_minimal,
      )

      // Recursively process right half (after partition point)
      loop_recursive(
        partition.xmid,
        xlim,
        partition.ymid,
        ylim,
        partition.hi_minimal,
      )
    }
  }

  // Start recursively processing entire region
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
fn[T : Eq + Hash] make_indexer(
  a : MutArrayView[T],
  b : MutArrayView[T],
) -> Array[Int] {
  let n = a.length()
  let htb : Map[T, T] = Map::new() // hash table for element deduplication and unification

  // Step 1: process array b, establish mapping from elements to unique objects
  // This ensures same elements have only one copy in memory
  for i = 0; i < b.length(); i = i + 1 {
    match htb.get(b[i]) {
      Some(v) => b[i] = v // already exists, use unified object reference
      None => htb[b[i]] = b[i] // new element, add to mapping
    }
  }
  let ai = Array::make(n, 0) // temporary storage for valid indices
  let mut k = 0 // valid element count

  // Step 2: process array a, find elements that also exist in b
  for i = 0; i < n; i = i + 1 {
    match htb.get(a[i]) {
      Some(v) => {
        a[i] = v // unify object reference, enabling subsequent comparison with physical_equal
        ai[k] = i // record original index of this element
        k += 1
      }
      None => () // doesn't exist in b, skip
    }
  }
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
  a : MutArrayView[T],
  b : MutArrayView[T],
) -> (Array[Bool], Array[Bool]) {
  // Generate indexers: find elements that also exist in other array
  let ai = make_indexer(a, b) // indices of a elements that exist in b
  let bi = make_indexer(b, a) // indices of b elements that exist in a
  let n = ai.length() // number of valid elements (a)
  let m = bi.length() // number of valid elements (b)

  // Call main loop for difference computation
  diff_loop(cutoff, a, ai, b, bi, n, m)
}

///|
/// `iter_matches(?cutoff, old~, new~)` diffs the arrays `old~` and `new~` (as in /usr/bin/diff),
/// and returns index pair of longest common subsequence in increasing order. 
///
/// The `cutoff` is an upper bound on the minimum edit distance between `old~` and `new~`. When
/// `cutoff` is exceeded, `iter_matches` returns a correct, but not necessarily minimal
/// diff. It defaults to about `sqrt(a.length() + b.length())`.
fn[T : Eq + Hash] iter_matches(
  cutoff~ : Int?, // optional computation cost limit
  old~ : Array[T], // original array
  old_start~ : Int,
  old_end~ : Int,
  new~ : Array[T], // new array
  new_start~ : Int,
  new_end~ : Int,
) -> Iter2[Int, Int] {
  // First compute difference markers
  let (d1, d2) = diff(
    cutoff,
    old.mut_view(start=old_start, end=old_end),
    new.mut_view(start=new_start, end=new_end),
  )
  Iter2::new(fn(yield_) {
    // traverse two arrays, find unchanged element pairs
    for i1 = 0, i2 = 0 {
      if i1 >= d1.length() || i2 >= d2.length() {
        return IterEnd // reached end of arrays
      } else if not(d1[i1]) {
        // old[i1] unchanged
        if not(d2[i2]) {
          // new[i2] also unchanged - found matching pair
          guard yield_(i1 + old_start, i2 + new_start) is IterContinue else {
            return IterEnd
          }
          continue i1 + 1, i2 + 1 // advance both
        } else {
          // new[i2] changed (insertion) - skip element in new
          continue i1, i2 + 1
        }
      } else if not(d2[i2]) {
        // old[i1] changed but new[i2] didn't (deletion) - skip element in old  
        continue i1 + 1, i2
      } else {
        // both elements changed - advance both to find next possible match
        continue i1 + 1, i2 + 1
      }
    }
  })
}

///|
pub fn[T : Hash + Eq] plain_diff(
  old~ : Array[T],
  new~ : Array[T],
  cutoff? : Int,
  old_start? : Int = 0,
  old_end? : Int = old.length(),
  new_start? : Int = 0,
  new_end? : Int = new.length(),
) -> Array[Edit] {
  let result = Array::new(capacity=old.length() + new.length())
  let mut prev_old_idx = 0
  let mut prev_new_idx = 0
  let mut equal_old_idx = 0
  let mut equal_new_idx = 0
  let mut consecutive_equal_length = 0
  for
    old_idx, new_idx in iter_matches(
      old~,
      new~,
      cutoff~,
      old_start~,
      old_end~,
      new_start~,
      new_end~,
    ) {
    // emit delete
    if prev_old_idx != old_idx {
      if consecutive_equal_length != 0 {
        result.push(
          Equal(
            old_index=equal_old_idx,
            new_index=equal_new_idx,
            len=consecutive_equal_length,
          ),
        )
      }
      consecutive_equal_length = 0
      result.push(
        Delete(
          old_index=prev_old_idx,
          new_index=prev_new_idx,
          old_len=old_idx - prev_old_idx,
        ),
      )
    }
    // emit insert
    if prev_new_idx != new_idx {
      if consecutive_equal_length != 0 {
        result.push(
          Equal(
            old_index=equal_old_idx,
            new_index=equal_new_idx,
            len=consecutive_equal_length,
          ),
        )
      }
      consecutive_equal_length = 0
      result.push(
        Insert(
          old_index=prev_old_idx,
          new_index=prev_new_idx,
          new_len=new_idx - prev_new_idx,
        ),
      )
    }
    prev_old_idx = old_idx + 1
    prev_new_idx = new_idx + 1
    // emit equal
    if consecutive_equal_length == 0 {
      equal_old_idx = old_idx
      equal_new_idx = new_idx
      consecutive_equal_length = 1
    } else {
      consecutive_equal_length += 1
    }
  } else {
    // emit remain equal
    if consecutive_equal_length != 0 {
      result.push(
        Equal(
          old_index=equal_old_idx,
          new_index=equal_new_idx,
          len=consecutive_equal_length,
        ),
      )
    }
    // emit remaining deletions
    if prev_old_idx != old.length() {
      result.push(
        Delete(
          old_index=prev_old_idx,
          new_index=prev_new_idx,
          old_len=old.length() - prev_old_idx,
        ),
      )
      // update prev_old_idx
      prev_old_idx = old.length()
    }

    // emit remaining insertions

    if prev_new_idx != new.length() {
      result.push(
        Insert(
          old_index=prev_old_idx,
          new_index=prev_new_idx,
          new_len=new.length() - prev_new_idx,
        ),
      )
    }
    return result
  }
}
