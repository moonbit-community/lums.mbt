///|UUID(c6602a07-bbb4-4781-8638-0b27709a127a)
test "condense into one equal" {
  let old = [
    "apple", "pineapple", "banana", "tomato", "carrot", "tomato", "potato", "cabbage",
  ].mut_view()
  let new = [
    "apple", "pineapple", "banana", "tomato", "carrot", "tomato", "potato", "cabbage",
  ].mut_view()
  assert_eq(old, new)
  inspect(
    plain_diff(old~, new~),
    content="[Equal(old_index=0, new_index=0, len=8)]",
  )
}

///|UUID(555d8748-4fd1-4436-a356-97c05e5da1a3)
test "mixed" {
  let old = ["carrot", "tomato", "potato", "cabbage"].mut_view()
  let new = ["apple", "banana", "tomato", "pineapple"].mut_view()
  json_inspect(plain_diff(old~, new~), content=[
    ["Delete", { "old_index": 0, "new_index": 0, "old_len": 1 }],
    ["Insert", { "old_index": 0, "new_index": 0, "new_len": 2 }],
    ["Equal", { "old_index": 1, "new_index": 2, "len": 1 }],
    ["Delete", { "old_index": 2, "new_index": 3, "old_len": 2 }],
    ["Insert", { "old_index": 4, "new_index": 3, "new_len": 1 }],
  ])
}

///|UUID(6c847c67-8117-4e00-9831-892180c0ebdf)
test "delete then insert to hunks" {
  let old = ["fn main() {", "  println(\"foo\")", "}"].mut_view()
  let new = ["fn main() {", "  println(\"bar\")", "}"].mut_view()
  let edits = plain_diff(old~, new~)
  json_inspect(edits, content=[
    ["Equal", { "old_index": 0, "new_index": 0, "len": 1 }],
    ["Delete", { "old_index": 1, "new_index": 1, "old_len": 1 }],
    ["Insert", { "old_index": 1, "new_index": 1, "new_len": 1 }],
    ["Equal", { "old_index": 2, "new_index": 2, "len": 1 }],
  ])
  json_inspect(@edit.group_edits(edits), content=[
    [
      ["Equal", { "old_index": 0, "new_index": 0, "len": 1 }],
      ["Delete", { "old_index": 1, "new_index": 1, "old_len": 1 }],
      ["Insert", { "old_index": 1, "new_index": 1, "new_len": 1 }],
      ["Equal", { "old_index": 2, "new_index": 2, "len": 1 }],
    ],
  ])
}

///|UUID(47aa9b53-bfd7-4fed-b5ee-aa26fcf4bc7b)
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
  json_inspect(edits, content=[
    ["Equal", { "old_index": 0, "new_index": 0, "len": 5 }],
    ["Delete", { "old_index": 5, "new_index": 5, "old_len": 1 }],
    ["Insert", { "old_index": 5, "new_index": 5, "new_len": 1 }],
    ["Equal", { "old_index": 6, "new_index": 6, "len": 6 }],
  ])
  json_inspect(@edit.group_edits(edits), content=[
    [
      ["Equal", { "old_index": 2, "new_index": 2, "len": 3 }],
      ["Delete", { "old_index": 5, "new_index": 5, "old_len": 1 }],
      ["Insert", { "old_index": 5, "new_index": 5, "new_len": 1 }],
      ["Equal", { "old_index": 6, "new_index": 6, "len": 3 }],
    ],
  ])
}

///|
test "cutoff keeps insert between equal ranges" {
  let old = [1, 2].mut_view()
  let new = [1, 3, 2].mut_view()
  json_inspect(plain_diff(old~, new~, cutoff=1), content=[
    ["Equal", { "old_index": 0, "new_index": 0, "len": 1 }],
    ["Insert", { "old_index": 1, "new_index": 1, "new_len": 1 }],
    ["Equal", { "old_index": 1, "new_index": 2, "len": 1 }],
  ])
}
