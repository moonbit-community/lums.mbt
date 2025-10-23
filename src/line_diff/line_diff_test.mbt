///|
test "insert/delete in middle" {
  let old =
    #|fn main() {
    #|  println("foo")
    #|}
  let new =
    #|fn main() {
    #|  println("bar")
    #|}
  inspect(
    line_diff(old~, new~),
    content=(
      #|   fn main() {
      #| -   println("foo")
      #| +   println("bar")
      #|   }
      #|
    ),
  )
}

///|
test "identical inputs" {
  let old =
    #|a
    #|b
    #|c
  let new = old
  inspect(
    line_diff(old~, new~),
    content=(
      #|   a
      #|   b
      #|   c
      #|
    ),
  )
}

///|
test "insert at beginning" {
  let old =
    #|b
    #|c
  let new =
    #|a
    #|b
    #|c
  inspect(
    line_diff(old~, new~),
    content=(
      #| + a
      #|   b
      #|   c
      #|
    ),
  )
}

///|
test "insert at end" {
  let old =
    #|a
    #|b
  let new =
    #|a
    #|b
    #|c
  inspect(
    line_diff(old~, new~),
    content=(
      #|   a
      #|   b
      #| + c
      #|
    ),
  )
}

///|
test "delete at beginning" {
  let old =
    #|a
    #|b
    #|c
  let new =
    #|b
    #|c
  inspect(
    line_diff(old~, new~),
    content=(
      #| - a
      #|   b
      #|   c
      #|
    ),
  )
}

///|
test "delete at end" {
  let old =
    #|a
    #|b
    #|c
  let new =
    #|a
    #|b
  inspect(
    line_diff(old~, new~),
    content=(
      #|   a
      #|   b
      #| - c
      #|
    ),
  )
}

///|
test "blank lines and unicode" {
  let old =
    #|
    #|你
    #|
    #|好
  let new =
    #|
    #|你
    #|世
    #|界
  inspect(
    line_diff(old~, new~),
    content=(
      #|   
      #|   你
      #| - 
      #| - 好
      #| + 世
      #| + 界
      #|
    ),
  )
}

///|
test "no trailing newline behavior" {
  // Both inputs here end without a trailing newline implicitly; the lines() splitter
  // still treats them as single lines.
  let old =
    #|last
  let new =
    #|last
  inspect(
    line_diff(old~, new~),
    content=(
      #|   last
      #|
    ),
  )
}

///|
test "multiple insert/delete" {
  let old =
    #|carrot
    #|tomato
    #|potato
    #|cabbage
  let new =
    #|apple
    #|banana
    #|tomato
    #|pineapple
  inspect(
    line_diff(old~, new~),
    content=(
      #| - carrot
      #| + apple
      #| + banana
      #|   tomato
      #| - potato
      #| - cabbage
      #| + pineapple
      #|
    ),
  )
  inspect(
    line_diff(old~, new~, output_line_number=true),
    content=(
      #|1     - carrot
      #|   1  + apple
      #|   2  + banana
      #|2  3    tomato
      #|3     - potato
      #|4     - cabbage
      #|   4  + pineapple
      #|
    ),
  )
}
