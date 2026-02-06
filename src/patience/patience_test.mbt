///|
test {
  let old =
    #|fn main() {
    #|  println("foo")
    #|}
  let new =
    #|fn main() {
    #|  println("bar")
    #|}
  json_inspect(
    patience_diff(
      old=old.split("\n").collect().mut_view(),
      new=new.split("\n").collect().mut_view(),
    ),
    content=[
      ["Equal", { "old_index": 0, "new_index": 0, "len": 1 }],
      ["Delete", { "old_index": 1, "new_index": 1, "old_len": 1 }],
      ["Insert", { "old_index": 2, "new_index": 1, "new_len": 1 }],
      ["Equal", { "old_index": 2, "new_index": 2, "len": 1 }],
    ],
  )
}

///|
test {
  let old = ["a", "b", "c"].mut_view()
  let new = ["a", "b"].mut_view()
  json_inspect(patience_diff(old~, new~), content=[
    ["Equal", { "old_index": 0, "new_index": 0, "len": 2 }],
    ["Delete", { "old_index": 2, "new_index": 2, "old_len": 1 }],
  ])
}

///|
test "patience diff with cutoff" {
  let old = ["a", "b", "c"].mut_view()
  let new = ["a", "x", "c"].mut_view()
  json_inspect(patience_diff(old~, new~, cutoff=1), content=[
    ["Equal", { "old_index": 0, "new_index": 0, "len": 1 }],
    ["Delete", { "old_index": 1, "new_index": 1, "old_len": 1 }],
    ["Insert", { "old_index": 2, "new_index": 1, "new_len": 1 }],
    ["Equal", { "old_index": 2, "new_index": 2, "len": 1 }],
  ])
}
