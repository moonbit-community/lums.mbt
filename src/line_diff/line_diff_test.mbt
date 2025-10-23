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
  inspect(
    line_diff(old~, new~),
    content=(
      #|  fn main() {
      #|-   println("foo")
      #|+   println("bar")
      #|  }
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
      #|  a
      #|  b
      #|  c
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
      #|+ a
      #|  b
      #|  c
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
      #|  a
      #|  b
      #|+ c
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
      #|- a
      #|  b
      #|  c
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
      #|  a
      #|  b
      #|- c
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
      #|  你
      #|- 
      #|- 好
      #|+ 世
      #|+ 界
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
      #|  last
      #|
    ),
  )
}
