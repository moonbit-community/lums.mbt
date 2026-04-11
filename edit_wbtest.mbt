///|
test "group_edit handles empty edits" {
  assert_true(
    group_edits([], old=([] : ArrayView[Int]), new=([] : ArrayView[Int])) is [],
  )
}

///|
test "group_edit splits long equal blocks into multiple hunks" {
  let edits : Array[Edit] = [
    Edit::Delete(old_index=0, new_index=0, len=1),
    Edit::Equal(old_index=1, new_index=0, len=10),
    Edit::Insert(old_index=11, new_index=10, len=2),
  ]
  let groups = group_edits(
    edits,
    old=([] : ArrayView[Int]),
    new=([] : ArrayView[Int]),
  )
  assert_eq(groups.length(), 2)
  assert_true(
    groups[0].edits
    is [
      Delete(old_index=0, new_index=0, len=1),
      Equal(old_index=1, new_index=0, len=3),
    ],
  )
  assert_true(
    groups[1].edits
    is [
      Equal(old_index=8, new_index=7, len=3),
      Insert(old_index=11, new_index=10, len=2),
    ],
  )
}

///|
test "range display for single and empty span" {
  inspect(
    HunkHeader::new([Equal(old_index=4, new_index=2, len=1)]).to_string(),
    content="@@ -5 +3 @@",
  )
  inspect(
    HunkHeader::new([Insert(old_index=4, new_index=2, len=1)]).to_string(),
    content="@@ -4,0 +3 @@",
  )
}

///|
test "range display spans replacement ending with insert" {
  inspect(
    HunkHeader::new([
      Delete(old_index=1, new_index=1, len=1),
      Insert(old_index=1, new_index=1, len=1),
    ]).to_string(),
    content="@@ -2 +2 @@",
  )
}
