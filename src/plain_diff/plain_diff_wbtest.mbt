///|UUID(aed6276f-dcf0-42b9-8607-fd5305ba7c93)
fn print_edits(
  cutoff? : Int,
  old : MutArrayView[String],
  new : MutArrayView[String],
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
  for old_idx, new_idx in iter_matches(cutoff~, old~, new~) {
    callback(old_idx, new_idx)
  }
  for i in prev_old_idx..<old.length() {
    result.push("-  " + old[i])
  }
  for i in prev_new_idx..<new.length() {
    result.push("+  " + new[i])
  }
  return result.join("\n")
}

///|UUID(c3e77336-83fb-4659-80ae-dfca130f6ef2)
test {
  let old = ['a', 'b', 'c', 'd', 'e'].map(String::make(3, _))
  let new = ['a', 'x', 'c', 'y', 'e', 'z'].map(String::make(3, _))
  inspect(
    print_edits(old.mut_view(), new.mut_view()),
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

///|UUID(b0589b99-566b-424c-adc3-36d92667827b)
test {
  let old = ['a', 'o', 'b', 'c'].map(String::make(3, _))
  let new = ['a', 'e', 'b', 'c'].map(String::make(3, _))
  inspect(
    print_edits(old.mut_view(), new.mut_view()),
    content=(
      #|   aaa
      #|-  ooo
      #|+  eee
      #|   bbb
      #|   ccc
    ),
  )
}

///|UUID(e3170114-f099-48c0-b609-f55280ab5d10)
test "identical arrays" {
  let old = ['a', 'b', 'c', 'd', 'e'].map(String::make(3, _))
  let new = ['a', 'b', 'c', 'd', 'e'].map(String::make(3, _))
  inspect(
    print_edits(old.mut_view(), new.mut_view()),
    content=(
      #|   aaa
      #|   bbb
      #|   ccc
      #|   ddd
      #|   eee
    ),
  )
}

///|UUID(bcc1ec37-2610-49bc-9e87-bb0d89d117ed)
test "completely different arrays" {
  let old = ['a', 'b', 'c'].map(String::make(3, _))
  let new = ['x', 'y', 'z'].map(String::make(3, _))
  inspect(
    print_edits(old.mut_view(), new.mut_view()),
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

///|UUID(54ddf829-1b13-418a-b986-50ae735b5bdf)
test "fully insert" {
  let old : Array[String] = []
  let new = ['a', 'b', 'c'].map(String::make(3, _))
  inspect(
    print_edits(old.mut_view(), new.mut_view()),
    content=(
      #|+  aaa
      #|+  bbb
      #|+  ccc
    ),
  )
}

///|UUID(56916565-5750-4055-b9b3-a1f6fa78a4bd)
test "fully delete" {
  let old = ['a', 'b', 'c'].map(String::make(3, _))
  let new : Array[String] = []
  inspect(
    print_edits(old.mut_view(), new.mut_view()),
    content=(
      #|-  aaa
      #|-  bbb
      #|-  ccc
    ),
  )
}

///|UUID(461d5b63-5fb1-47fd-ae0b-025114f299d8)
test "insert at beginning" {
  let old = ['b', 'c', 'd'].map(String::make(3, _))
  let new = ['a', 'b', 'c', 'd'].map(String::make(3, _))
  inspect(
    print_edits(old.mut_view(), new.mut_view()),
    content=(
      #|+  aaa
      #|   bbb
      #|   ccc
      #|   ddd
    ),
  )
}

///|UUID(7ab8dc67-69f2-49ae-b97f-2a4f3e096867)
test "insert at end" {
  let old = ['a', 'b', 'c'].map(String::make(3, _))
  let new = ['a', 'b', 'c', 'd'].map(String::make(3, _))
  inspect(
    print_edits(old.mut_view(), new.mut_view()),
    content=(
      #|   aaa
      #|   bbb
      #|   ccc
      #|+  ddd
    ),
  )
}

///|UUID(5c8b1c5f-2072-4736-aa50-6a1b29e60600)
test "delete at beginning" {
  let old = ['a', 'b', 'c', 'd'].map(String::make(3, _))
  let new = ['b', 'c', 'd'].map(String::make(3, _))
  inspect(
    print_edits(old.mut_view(), new.mut_view()),
    content=(
      #|-  aaa
      #|   bbb
      #|   ccc
      #|   ddd
    ),
  )
}

///|UUID(2f5f895c-7e6a-4507-ae56-8e4aeb6e34d1)
test "delete at end" {
  let old = ['a', 'b', 'c', 'd'].map(String::make(3, _))
  let new = ['a', 'b', 'c'].map(String::make(3, _))
  inspect(
    print_edits(old.mut_view(), new.mut_view()),
    content=(
      #|   aaa
      #|   bbb
      #|   ccc
      #|-  ddd
    ),
  )
}

///|UUID(cb4583ba-3ef4-435e-9851-5c1de01a9e42)
test "insert multiple in middle" {
  let old = ['a', 'b', 'e', 'f'].map(String::make(3, _))
  let new = ['a', 'b', 'c', 'd', 'e', 'f'].map(String::make(3, _))
  inspect(
    print_edits(old.mut_view(), new.mut_view()),
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

///|UUID(d1b9e618-2050-4747-a872-5a7a4637f3af)
test "delete multiple in middle" {
  let old = ['a', 'b', 'c', 'd', 'e', 'f'].map(String::make(3, _))
  let new = ['a', 'b', 'e', 'f'].map(String::make(3, _))
  inspect(
    print_edits(old.mut_view(), new.mut_view()),
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

///|UUID(87d31182-b921-4b0e-b0f7-162d898d19cb)
test "arrays with duplicates" {
  let old = ['a', 'b', 'a', 'c'].map(String::make(3, _))
  let new = ['a', 'a', 'b', 'c'].map(String::make(3, _))
  inspect(
    print_edits(old.mut_view(), new.mut_view()),
    content=(
      #|   aaa
      #|-  bbb
      #|   aaa
      #|+  bbb
      #|   ccc
    ),
  )
}

///|UUID(d4c47e17-c9ba-4059-bf3c-a9a8e016ef0e)
test "single element arrays" {
  let old = ['a'].map(String::make(3, _))
  let new = ['b'].map(String::make(3, _))
  inspect(
    print_edits(old.mut_view(), new.mut_view()),
    content=(
      #|-  aaa
      #|+  bbb
    ),
  )
}

///|UUID(c01d74b9-9e44-4870-97e0-a433f7b178b2)
test "long sequence LCS" {
  let old = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'].map(x0 => String::make(
    3, x0,
  ))
  let new = ['a', 'x', 'c', 'y', 'e', 'z', 'g', 'w', 'i', 'v'].map(x0 => String::make(
    3, x0,
  ))
  inspect(
    print_edits(old.mut_view(), new.mut_view()),
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

///|UUID(1211b79f-f20b-4cb7-a933-a731792f8555)
test "reverse order" {
  let old = ['a', 'b', 'c', 'd'].map(String::make(3, _))
  let new = ['d', 'c', 'b', 'a'].map(String::make(3, _))
  inspect(
    print_edits(old.mut_view(), new.mut_view()),
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

///|UUID(a38906d4-04f0-444e-873c-eb07cdceb2f8)
test "integer arrays diff" {
  let old = [1, 2, 3, 4, 5].mut_view()
  let new = [1, 3, 5, 6, 7].mut_view()
  let result = Array::new()
  for old_idx, new_idx in iter_matches(old~, new~, cutoff=None) {
    result.push((old_idx, new_idx))
  }

  // Should find matching elements: (0,0)=1, (2,1)=3, (4,2)=5
  inspect(result, content="[(0, 0), (2, 1), (4, 2)]")
}

///|UUID(7aed1faf-bb2c-485a-b1d2-1ebcaff5be7f)
test "many duplicate elements" {
  let old = ['a', 'a', 'a', 'b', 'a', 'a'].map(String::make(3, _))
  let new = ['a', 'a', 'b', 'a', 'a', 'a'].map(String::make(3, _))
  inspect(
    print_edits(old.mut_view(), new.mut_view()),
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

///|UUID(243761c6-0b87-4db5-a245-911699ae5713)
test "alternating pattern" {
  let old = ['a', 'b', 'a', 'b', 'a', 'b'].map(String::make(3, _))
  let new = ['b', 'a', 'b', 'a', 'b', 'a'].map(String::make(3, _))
  inspect(
    print_edits(old.mut_view(), new.mut_view()),
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

///|UUID(d72c7fe6-dd93-449b-8c7d-cfafb876f7ab)
test "nested insertions and deletions" {
  let old = ['a', 'x', 'b', 'y', 'c', 'z', 'd'].map(String::make(3, _))
  let new = ['a', 'b', 'c', 'd', 'e'].map(String::make(3, _))
  inspect(
    print_edits(old.mut_view(), new.mut_view()),
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

///|UUID(335f12d9-8e17-48f8-994b-793aa8326076)
test "iter_matches callback verification" {
  let old = ['a', 'b', 'c', 'd'].map(String::make(3, _)).mut_view()
  let new = ['a', 'x', 'c', 'y'].map(String::make(3, _)).mut_view()
  let matches = Array::new()
  let old_indices = Array::new()
  let new_indices = Array::new()
  for old_idx, new_idx in iter_matches(old~, new~, cutoff=None) {
    matches.push((old_idx, new_idx))
    old_indices.push(old_idx)
    new_indices.push(new_idx)
  }

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

///|UUID(c3124240-e24f-41d6-9f2c-32e793a3e2ad)
test "string array edge cases" {
  let old = ["", "a", "", "b", ""].mut_view()
  let new = ["", "b", "", "a", ""].mut_view()
  let result = Array::new()
  for old_idx, new_idx in iter_matches(old~, new~, cutoff=None) {
    result.push((old_idx, new_idx))
  }

  // Should find some matches (empty strings will match)
  inspect(result.length() > 0, content="true")
}

///|UUID(7ca8804c-6cf8-4b90-bc3f-b9a5a73cb05f)
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
  for
    _old_idx, _new_idx in iter_matches(
      old=old.mut_view(),
      new=new.mut_view(),
      cutoff=None,
    ) {
    match_count.val = match_count.val + 1
  }

  // Should find approximately half matches
  inspect(match_count.val > 10, content="true")
  inspect(match_count.val < 40, content="true")
}

///|UUID(288595ae-87ca-4a11-af0b-4f95a2b47f23)
test "single difference" {
  let old = ['a', 'b', 'c', 'd', 'e'].map(String::make(3, _))
  let new = ['a', 'b', 'x', 'd', 'e'].map(String::make(3, _))
  inspect(
    print_edits(old.mut_view(), new.mut_view()),
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

///|UUID(b80aa5ad-ac7c-49e1-8eea-c09bb1db3d09)
test "very short arrays" {
  let old = ['a'].map(String::make(3, _))
  let new : Array[String] = []
  inspect(
    print_edits(old.mut_view(), new.mut_view()),
    content=(
      #|-  aaa
    ),
  )
}

///|UUID(c87a7729-fd43-4d41-bce8-058b819a0c1d)
test "partial overlap sequence" {
  let old = ['a', 'b', 'c', 'd'].map(String::make(3, _))
  let new = ['c', 'd', 'e', 'f'].map(String::make(3, _))
  inspect(
    print_edits(old.mut_view(), new.mut_view()),
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

///|UUID(5dd9bbdb-0127-47c2-b89c-bd22062f6979)
test "iter_matches parameter order" {
  let old = ['a', 'b', 'c'].map(String::make(3, _)).mut_view()
  let new = ['a', 'x', 'c'].map(String::make(3, _)).mut_view()
  let matches = Array::new()
  let all_equal = Ref::new(true)
  for old_idx, new_idx in iter_matches(old~, new~, cutoff=None) {
    // Verify parameter order: old_idx should correspond to old array, new_idx to new array
    let old_val = old[old_idx]
    let new_val = new[new_idx]
    if old_val != new_val {
      all_equal.val = false
    }
    matches.push("old[\{old_idx}]=\{old_val}, new[\{new_idx}]=\{new_val}")
  }

  // Verify that all matched elements are indeed equal
  assert_true(all_equal.val)
  // Should have matches for 'a' and 'c'
  inspect(matches.length(), content="2")
}

///|UUID(bf229449-a759-47a0-b27d-9bf179b419e6)
test "repeated subsequence" {
  let old = ['a', 'b', 'a', 'b', 'c'].map(String::make(3, _)).mut_view()
  let new = ['a', 'b', 'c', 'a', 'b'].map(String::make(3, _)).mut_view()
  let result = Array::new()
  for old_idx, new_idx in iter_matches(old~, new~, cutoff=None) {
    result.push((old_idx, new_idx))
  }

  // Verify that some matches were found
  inspect(result.length() >= 3, content="true")
}

///|UUID(d3805dfa-4b2e-4406-975a-e5e36271a313)
test "diff symmetry test" {
  let arr1 = ['a', 'b', 'c'].map(String::make(3, _)).mut_view()
  let arr2 = ['a', 'x', 'c'].map(String::make(3, _)).mut_view()

  // Calculate diff from arr1 -> arr2
  let matches1 = Array::new()
  for old_idx, new_idx in iter_matches(old=arr1, new=arr2, cutoff=None) {
    matches1.push((old_idx, new_idx))
  }

  // Calculate diff from arr2 -> arr1
  let matches2 = Array::new()
  for old_idx, new_idx in iter_matches(old=arr2, new=arr1, cutoff=None) {
    matches2.push((old_idx, new_idx))
  }

  // Both directions should have the same number of matches
  assert_eq(matches1.length(), matches2.length())
}

///|UUID(9cf3bc8b-a46b-40f5-87c3-68af63b3c3e8)
test "diff sub array" {
  let old = [
    "Apple", "Banana", "Orange", "Grape", "Strawberry", "Watermelon", "Peach", "Pear",
    "Pineapple", "Cherry",
  ]
  let new = [
    "Apple", "Banana", "Orange", "Grape", "Strawberry", "Watermelon", "Peach", "Pear",
    "Pineapple", "Cherry",
  ]
  assert_eq(old, new)
  inspect(
    print_edits(old.mut_view(end=4), new.mut_view(end=5)),
    content=(
      #|   Apple
      #|   Banana
      #|   Orange
      #|   Grape
      #|+  Strawberry
    ),
  )
  inspect(
    print_edits(old.mut_view(start=4), new.mut_view(start=5)),
    content=(
      #|-  Strawberry
      #|   Watermelon
      #|   Peach
      #|   Pear
      #|   Pineapple
      #|   Cherry
    ),
  )
}
