///|
fn run_diag_range(
  old : Array[Int],
  new : Array[Int],
  xoff : Int,
  xlim : Int,
  yoff : Int,
  ylim : Int,
  too_expensive : Int,
  find_minimal : Bool,
) -> Partition {
  let fd = FixedArray::make(old.length() + new.length() + 3, 0)
  let bd = FixedArray::make(old.length() + new.length() + 3, 0)
  let sh = new.length() + 1
  diag(
    fd~,
    bd~,
    sh~,
    xv=fn(i) { old[i] },
    yv=fn(i) { new[i] },
    xoff~,
    xlim~,
    yoff~,
    ylim~,
    too_expensive~,
    find_minimal~,
  )
}

///|
fn run_diag(
  old : Array[Int],
  new : Array[Int],
  too_expensive : Int,
  find_minimal : Bool,
) -> Partition {
  run_diag_range(
    old,
    new,
    0,
    old.length(),
    0,
    new.length(),
    too_expensive,
    find_minimal,
  )
}

///|
fn patterned_array(length : Int, shift : Int, modulo : Int) -> Array[Int] {
  let result = Array::make(length, 0)
  for i = 0; i < length; i = i + 1 {
    result[i] = (i + shift) % modulo
  }
  result
}

///|
test "diag reaches lower diagonal boundary when old is longer" {
  let partition = run_diag([1, 2, 3, 4, 5], [10], 1024, true)
  assert_true(partition.lo_minimal)
  assert_true(partition.hi_minimal)
  assert_true(partition.xmid >= 0 && partition.xmid <= 5)
  assert_true(partition.ymid >= 0 && partition.ymid <= 1)
}

///|
test "diag reaches upper diagonal boundary when new is longer" {
  let partition = run_diag([1], [10, 11, 12, 13, 14], 1024, true)
  assert_true(partition.lo_minimal)
  assert_true(partition.hi_minimal)
  assert_true(partition.xmid >= 0 && partition.xmid <= 1)
  assert_true(partition.ymid >= 0 && partition.ymid <= 5)
}

///|
test "diag odd parity can return from forward search" {
  let partition = run_diag([1, 2], [9], 1024, true)
  assert_true(partition.lo_minimal)
  assert_true(partition.hi_minimal)
}

///|
test "diag heuristic path can choose either side" {
  let saw_forward = Ref::new(false)
  let saw_backward = Ref::new(false)
  for n = 3; n <= 8; n = n + 1 {
    for m = 3; m <= 8; m = m + 1 {
      for old_shift = 0; old_shift < 5; old_shift = old_shift + 1 {
        for new_shift = 0; new_shift < 5; new_shift = new_shift + 1 {
          let old = patterned_array(n, old_shift, 5)
          let new = patterned_array(m, new_shift, 5)
          for xoff = 0; xoff <= 1; xoff = xoff + 1 {
            for yoff = 0; yoff <= 1; yoff = yoff + 1 {
              if xoff < n && yoff < m {
                let partition = run_diag_range(
                  old, new, xoff, n, yoff, m, 0, false,
                )
                if partition.lo_minimal && not(partition.hi_minimal) {
                  saw_forward.val = true
                }
                if not(partition.lo_minimal) && partition.hi_minimal {
                  saw_backward.val = true
                }
              }
            }
          }
        }
      }
    }
  }
  assert_true(saw_forward.val)
  assert_true(saw_backward.val)
}
