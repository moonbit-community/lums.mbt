///|
fn print_edits(
  cutoff? : Int,
  old : Array[String],
  new : Array[String],
) -> String {
  let mut prev_old_idx = 0
  let mut prev_new_idx = 0
  let result = Array::new(capacity=old.length() + new.length())
  let callback = fn(old_idx, new_idx) {
    for i in prev_old_idx..<old_idx {
      result.push("-  " + old[i])
    }
    for i in prev_new_idx..<new_idx {
      result.push("+  " + new[i])
    }
    result.push("   \{old[old_idx]}")
    prev_old_idx = old_idx + 1
    prev_new_idx = new_idx + 1
  }
  match cutoff {
    Some(cutoff) => @plain_diff.iter_matches(cutoff~, old~, new~, callback)
    None => @plain_diff.iter_matches(old~, new~, callback)
  }
  for i in prev_old_idx..<old.length() {
    result.push("-  " + old[i])
  }
  for i in prev_new_idx..<new.length() {
    result.push("+  " + new[i])
  }
  return result.join("\n")
}

///|
test {
  let old = ['a', 'b', 'c', 'd', 'e'].map(String::make(3, _))
  let new = ['a', 'x', 'c', 'y', 'e', 'z'].map(String::make(3, _))
  inspect(
    print_edits(old, new),
    content=(
      #|   aaa
      #|-  bbb
      #|+  xxx
      #|   ccc
      #|-  ddd
      #|+  yyy
      #|   eee
      #|+  zzz
    ),
  )
}

///|
test {
  let old = ['a', 'o', 'b', 'c'].map(String::make(3, _))
  let new = ['a', 'e', 'b', 'c'].map(String::make(3, _))
  inspect(
    print_edits(old, new),
    content=(
      #|   aaa
      #|-  ooo
      #|+  eee
      #|   bbb
      #|   ccc
    ),
  )
}

///|
test "identical arrays" {
  let old = ['a', 'b', 'c', 'd', 'e'].map(String::make(3, _))
  let new = ['a', 'b', 'c', 'd', 'e'].map(String::make(3, _))
  inspect(
    print_edits(old, new),
    content=(
      #|   aaa
      #|   bbb
      #|   ccc
      #|   ddd
      #|   eee
    ),
  )
}

///|
test "completely different arrays" {
  let old = ['a', 'b', 'c'].map(String::make(3, _))
  let new = ['x', 'y', 'z'].map(String::make(3, _))
  inspect(
    print_edits(old, new),
    content=(
      #|-  aaa
      #|-  bbb
      #|-  ccc
      #|+  xxx
      #|+  yyy
      #|+  zzz
    ),
  )
}

///|
test "fully insert" {
  let old : Array[String] = []
  let new = ['a', 'b', 'c'].map(String::make(3, _))
  inspect(
    print_edits(old, new),
    content=(
      #|+  aaa
      #|+  bbb
      #|+  ccc
    ),
  )
}

///|
test "fully delete" {
  let old = ['a', 'b', 'c'].map(String::make(3, _))
  let new : Array[String] = []
  inspect(
    print_edits(old, new),
    content=(
      #|-  aaa
      #|-  bbb
      #|-  ccc
    ),
  )
}

///|
test "insert at beginning" {
  let old = ['b', 'c', 'd'].map(String::make(3, _))
  let new = ['a', 'b', 'c', 'd'].map(String::make(3, _))
  inspect(
    print_edits(old, new),
    content=(
      #|+  aaa
      #|   bbb
      #|   ccc
      #|   ddd
    ),
  )
}

///|
test "insert at end" {
  let old = ['a', 'b', 'c'].map(String::make(3, _))
  let new = ['a', 'b', 'c', 'd'].map(String::make(3, _))
  inspect(
    print_edits(old, new),
    content=(
      #|   aaa
      #|   bbb
      #|   ccc
      #|+  ddd
    ),
  )
}

///|
test "delete at beginning" {
  let old = ['a', 'b', 'c', 'd'].map(String::make(3, _))
  let new = ['b', 'c', 'd'].map(String::make(3, _))
  inspect(
    print_edits(old, new),
    content=(
      #|-  aaa
      #|   bbb
      #|   ccc
      #|   ddd
    ),
  )
}

///|
test "delete at end" {
  let old = ['a', 'b', 'c', 'd'].map(String::make(3, _))
  let new = ['a', 'b', 'c'].map(String::make(3, _))
  inspect(
    print_edits(old, new),
    content=(
      #|   aaa
      #|   bbb
      #|   ccc
      #|-  ddd
    ),
  )
}

///|
test "insert multiple in middle" {
  let old = ['a', 'b', 'e', 'f'].map(String::make(3, _))
  let new = ['a', 'b', 'c', 'd', 'e', 'f'].map(String::make(3, _))
  inspect(
    print_edits(old, new),
    content=(
      #|   aaa
      #|   bbb
      #|+  ccc
      #|+  ddd
      #|   eee
      #|   fff
    ),
  )
}

///|
test "delete multiple in middle" {
  let old = ['a', 'b', 'c', 'd', 'e', 'f'].map(String::make(3, _))
  let new = ['a', 'b', 'e', 'f'].map(String::make(3, _))
  inspect(
    print_edits(old, new),
    content=(
      #|   aaa
      #|   bbb
      #|-  ccc
      #|-  ddd
      #|   eee
      #|   fff
    ),
  )
}

///|
test "arrays with duplicates" {
  let old = ['a', 'b', 'a', 'c'].map(String::make(3, _))
  let new = ['a', 'a', 'b', 'c'].map(String::make(3, _))
  inspect(
    print_edits(old, new),
    content=(
      #|   aaa
      #|-  bbb
      #|   aaa
      #|+  bbb
      #|   ccc
    ),
  )
}

///|
test "single element arrays" {
  let old = ['a'].map(String::make(3, _))
  let new = ['b'].map(String::make(3, _))
  inspect(
    print_edits(old, new),
    content=(
      #|-  aaa
      #|+  bbb
    ),
  )
}

///|
test "long sequence LCS" {
  let old = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'].map(
    String::make(3, _),
  )
  let new = ['a', 'x', 'c', 'y', 'e', 'z', 'g', 'w', 'i', 'v'].map(
    String::make(3, _),
  )
  inspect(
    print_edits(old, new),
    content=(
      #|   aaa
      #|-  bbb
      #|+  xxx
      #|   ccc
      #|-  ddd
      #|+  yyy
      #|   eee
      #|-  fff
      #|+  zzz
      #|   ggg
      #|-  hhh
      #|+  www
      #|   iii
      #|-  jjj
      #|+  vvv
    ),
  )
}

///|
test "reverse order" {
  let old = ['a', 'b', 'c', 'd'].map(String::make(3, _))
  let new = ['d', 'c', 'b', 'a'].map(String::make(3, _))
  inspect(
    print_edits(old, new),
    content=(
      #|-  aaa
      #|-  bbb
      #|-  ccc
      #|   ddd
      #|+  ccc
      #|+  bbb
      #|+  aaa
    ),
  )
}

///|
test "integer arrays diff" {
  let old = [1, 2, 3, 4, 5]
  let new = [1, 3, 5, 6, 7]
  let result = Array::new()
  @plain_diff.iter_matches(
    fn(old_idx, new_idx) { result.push((old_idx, new_idx)) },
    old~,
    new~,
  )

  // Should find matching elements: (0,0)=1, (2,1)=3, (4,2)=5
  inspect(result, content="[(0, 0), (2, 1), (4, 2)]")
}

///|
test "many duplicate elements" {
  let old = ['a', 'a', 'a', 'b', 'a', 'a'].map(String::make(3, _))
  let new = ['a', 'a', 'b', 'a', 'a', 'a'].map(String::make(3, _))
  inspect(
    print_edits(old, new),
    content=(
      #|   aaa
      #|   aaa
      #|-  aaa
      #|   bbb
      #|+  aaa
      #|   aaa
      #|   aaa
    ),
  )
}

///|
test "alternating pattern" {
  let old = ['a', 'b', 'a', 'b', 'a', 'b'].map(String::make(3, _))
  let new = ['b', 'a', 'b', 'a', 'b', 'a'].map(String::make(3, _))
  inspect(
    print_edits(old, new),
    content=(
      #|-  aaa
      #|   bbb
      #|   aaa
      #|   bbb
      #|   aaa
      #|   bbb
      #|+  aaa
    ),
  )
}

///|
test "nested insertions and deletions" {
  let old = ['a', 'x', 'b', 'y', 'c', 'z', 'd'].map(String::make(3, _))
  let new = ['a', 'b', 'c', 'd', 'e'].map(String::make(3, _))
  inspect(
    print_edits(old, new),
    content=(
      #|   aaa
      #|-  xxx
      #|   bbb
      #|-  yyy
      #|   ccc
      #|-  zzz
      #|   ddd
      #|+  eee
    ),
  )
}

///|
test "iter_matches callback verification" {
  let old = ['a', 'b', 'c', 'd'].map(String::make(3, _))
  let new = ['a', 'x', 'c', 'y'].map(String::make(3, _))
  let matches = Array::new()
  let old_indices = Array::new()
  let new_indices = Array::new()
  @plain_diff.iter_matches(
    fn(old_idx, new_idx) {
      matches.push((old_idx, new_idx))
      old_indices.push(old_idx)
      new_indices.push(new_idx)
    },
    old~,
    new~,
  )

  // Verify that matched elements are indeed equal
  for i = 0; i < matches.length(); i = i + 1 {
    let (old_idx, new_idx) = matches[i]
    inspect(old[old_idx] == new[new_idx], content="true")
  }

  // Verify that indices are increasing
  for i = 1; i < old_indices.length(); i = i + 1 {
    inspect(old_indices[i] > old_indices[i - 1], content="true")
    inspect(new_indices[i] > new_indices[i - 1], content="true")
  }
}

///|
test "string array edge cases" {
  let old = ["", "a", "", "b", ""]
  let new = ["", "b", "", "a", ""]
  let result = Array::new()
  @plain_diff.iter_matches(
    fn(old_idx, new_idx) { result.push((old_idx, new_idx)) },
    old~,
    new~,
  )

  // Should find some matches (empty strings will match)
  inspect(result.length() > 0, content="true")
}

///|
test "large array performance" {
  let size = 50
  let old = Array::make(size, 0)
  let new = Array::make(size, 0)

  // Create regular pattern data
  for i = 0; i < size; i = i + 1 {
    old[i] = i
    new[i] = if i % 2 == 0 { i } else { i + 100 } // Half same, half different
  }
  let match_count = Ref::new(0)
  @plain_diff.iter_matches(
    fn(_old_idx, _new_idx) { match_count.val = match_count.val + 1 },
    old~,
    new~,
  )

  // Should find approximately half matches
  inspect(match_count.val > 10, content="true")
  inspect(match_count.val < 40, content="true")
}

///|
test "single difference" {
  let old = ['a', 'b', 'c', 'd', 'e'].map(String::make(3, _))
  let new = ['a', 'b', 'x', 'd', 'e'].map(String::make(3, _))
  inspect(
    print_edits(old, new),
    content=(
      #|   aaa
      #|   bbb
      #|-  ccc
      #|+  xxx
      #|   ddd
      #|   eee
    ),
  )
}

///|
test "very short arrays" {
  let old = ['a'].map(String::make(3, _))
  let new : Array[String] = []
  inspect(
    print_edits(old, new),
    content=(
      #|-  aaa
    ),
  )
}

///|
test "partial overlap sequence" {
  let old = ['a', 'b', 'c', 'd'].map(String::make(3, _))
  let new = ['c', 'd', 'e', 'f'].map(String::make(3, _))
  inspect(
    print_edits(old, new),
    content=(
      #|-  aaa
      #|-  bbb
      #|   ccc
      #|   ddd
      #|+  eee
      #|+  fff
    ),
  )
}

///|
test "iter_matches parameter order" {
  let old = ['a', 'b', 'c'].map(String::make(3, _))
  let new = ['a', 'x', 'c'].map(String::make(3, _))
  let matches = Array::new()
  let all_equal = Ref::new(true)
  @plain_diff.iter_matches(
    fn(old_idx, new_idx) {
      // Verify parameter order: old_idx should correspond to old array, new_idx to new array
      let old_val = old[old_idx]
      let new_val = new[new_idx]
      if old_val != new_val {
        all_equal.val = false
      }
      matches.push("old[\{old_idx}]=\{old_val}, new[\{new_idx}]=\{new_val}")
    },
    old~,
    new~,
  )

  // Verify that all matched elements are indeed equal
  assert_true(all_equal.val)
  // Should have matches for 'a' and 'c'
  inspect(matches.length(), content="2")
}

///|
test "repeated subsequence" {
  let old = ['a', 'b', 'a', 'b', 'c'].map(String::make(3, _))
  let new = ['a', 'b', 'c', 'a', 'b'].map(String::make(3, _))
  let result = Array::new()
  @plain_diff.iter_matches(
    fn(old_idx, new_idx) { result.push((old_idx, new_idx)) },
    old~,
    new~,
  )

  // Verify that some matches were found
  inspect(result.length() >= 3, content="true")
}

///|
test "diff symmetry test" {
  let arr1 = ['a', 'b', 'c'].map(String::make(3, _))
  let arr2 = ['a', 'x', 'c'].map(String::make(3, _))

  // Calculate diff from arr1 -> arr2
  let matches1 = Array::new()
  @plain_diff.iter_matches(
    fn(old_idx, new_idx) { matches1.push((old_idx, new_idx)) },
    old=arr1,
    new=arr2,
  )

  // Calculate diff from arr2 -> arr1
  let matches2 = Array::new()
  @plain_diff.iter_matches(
    fn(old_idx, new_idx) {
      matches2.push((new_idx, old_idx)) // Note parameter order is swapped
    },
    old=arr2,
    new=arr1,
  )

  // Both directions should have the same number of matches
  assert_eq(matches1.length(), matches2.length())
}
