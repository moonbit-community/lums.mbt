///|
test "condense into one equal" {
  let old = [
    "apple", "pineapple", "banana", "tomato", "carrot", "tomato", "potato", "cabbage",
  ].mut_view()
  let new = [
    "apple", "pineapple", "banana", "tomato", "carrot", "tomato", "potato", "cabbage",
  ].mut_view()
  assert_eq(old, new)
  debug_inspect(
    plain_diff(old~, new~),
    content="[Equal(old_index=0, new_index=0, len=8)]",
  )
}

///|
test "mixed" {
  let old = ["carrot", "tomato", "potato", "cabbage"].mut_view()
  let new = ["apple", "banana", "tomato", "pineapple"].mut_view()
  debug_inspect(
    plain_diff(old~, new~),
    content=(
      #|[
      #|  Delete(old_index=0, new_index=0, old_len=1),
      #|  Insert(old_index=0, new_index=0, new_len=2),
      #|  Equal(old_index=1, new_index=2, len=1),
      #|  Delete(old_index=2, new_index=3, old_len=2),
      #|  Insert(old_index=4, new_index=3, new_len=1),
      #|]
    ),
  )
}

///|
test "delete then insert to hunks" {
  let old = ["fn main() {", "  println(\"foo\")", "}"].mut_view()
  let new = ["fn main() {", "  println(\"bar\")", "}"].mut_view()
  let edits = plain_diff(old~, new~)
  debug_inspect(
    edits,
    content=(
      #|[
      #|  Equal(old_index=0, new_index=0, len=1),
      #|  Delete(old_index=1, new_index=1, old_len=1),
      #|  Insert(old_index=1, new_index=1, new_len=1),
      #|  Equal(old_index=2, new_index=2, len=1),
      #|]
    ),
  )
  debug_inspect(
    @plain_diff.group_edits(edits),
    content=(
      #|[
      #|  [
      #|    Equal(old_index=0, new_index=0, len=1),
      #|    Delete(old_index=1, new_index=1, old_len=1),
      #|    Insert(old_index=1, new_index=1, new_len=1),
      #|    Equal(old_index=2, new_index=2, len=1),
      #|  ],
      #|]
    ),
  )
}

///|
test "large text to hunks" {
  let old = [
    "alert", "chop", "brave", "arise", "bring", "boy", "answer", "count", "begin",
    "casual", "dot", "bottom",
  ].mut_view()
  let new = [
    "alert", "chop", "brave", "arise", "bring", "joy", "answer", "count", "begin",
    "casual", "dot", "bottom",
  ].mut_view()
  let edits = plain_diff(old~, new~)
  debug_inspect(
    edits,
    content=(
      #|[
      #|  Equal(old_index=0, new_index=0, len=5),
      #|  Delete(old_index=5, new_index=5, old_len=1),
      #|  Insert(old_index=5, new_index=5, new_len=1),
      #|  Equal(old_index=6, new_index=6, len=6),
      #|]
    ),
  )
  debug_inspect(
    @plain_diff.group_edits(edits),
    content=(
      #|[
      #|  [
      #|    Equal(old_index=2, new_index=2, len=3),
      #|    Delete(old_index=5, new_index=5, old_len=1),
      #|    Insert(old_index=5, new_index=5, new_len=1),
      #|    Equal(old_index=6, new_index=6, len=3),
      #|  ],
      #|]
    ),
  )
}

///|
test "cutoff keeps insert between equal ranges" {
  let old = [1, 2].mut_view()
  let new = [1, 3, 2].mut_view()
  debug_inspect(
    plain_diff(old~, new~, cutoff=1),
    content=(
      #|[
      #|  Equal(old_index=0, new_index=0, len=1),
      #|  Insert(old_index=1, new_index=1, new_len=1),
      #|  Equal(old_index=1, new_index=2, len=1),
      #|]
    ),
  )
}
