///|
fn print_hunks(
  hunks : Array[(@edit.HunkHeader, Array[(@edit.EditTag, StringView)])],
) -> String {
  let buf = StringBuilder::new()
  for hunk in hunks {
    buf.write_string(hunk.0.to_string())
    buf.write_char('\n')
    for edit in hunk.1 {
      match edit.0 {
        Ins => buf.write_string(" + ")
        Del => buf.write_string(" - ")
        Eql => buf.write_string("   ")
      }
      buf.write_stringview(edit.1)
      buf.write_char('\n')
    }
  }
  buf.to_string()
}

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
    print_hunks(line_diff(old~, new~)),
    content=(
      #|@@ -1,3 +1,3 @@
      #|   fn main() {
      #| -   println("foo")
      #| +   println("bar")
      #|   }
      #|
    ),
  )
  inspect(
    print_hunks(line_diff(old~, new~, patience=true)),
    content=(
      #|@@ -1,3 +1,3 @@
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
  inspect(print_hunks(line_diff(old~, new~)), content="")
  inspect(print_hunks(line_diff(old~, new~, patience=true)), content="")
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
    print_hunks(line_diff(old~, new~)),
    content=(
      #|@@ -1,2 +1,3 @@
      #| + a
      #|   b
      #|   c
      #|
    ),
  )
  inspect(
    print_hunks(line_diff(old~, new~, patience=true)),
    content=(
      #|@@ -1,2 +1,3 @@
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
    print_hunks(line_diff(old~, new~)),
    content=(
      #|@@ -1,2 +1,3 @@
      #|   a
      #|   b
      #| + c
      #|
    ),
  )
  inspect(
    print_hunks(line_diff(old~, new~, patience=true)),
    content=(
      #|@@ -1,2 +1,3 @@
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
    print_hunks(line_diff(old~, new~)),
    content=(
      #|@@ -1,3 +1,2 @@
      #| - a
      #|   b
      #|   c
      #|
    ),
  )
  inspect(
    print_hunks(line_diff(old~, new~, patience=true)),
    content=(
      #|@@ -1,3 +1,2 @@
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
    print_hunks(line_diff(old~, new~)),
    content=(
      #|@@ -1,3 +1,2 @@
      #|   a
      #|   b
      #| - c
      #|
    ),
  )
  inspect(
    print_hunks(line_diff(old~, new~, patience=true)),
    content=(
      #|@@ -1,3 +1,2 @@
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
    print_hunks(line_diff(old~, new~)),
    content=(
      #|@@ -1,4 +1,4 @@
      #|   
      #|   你
      #| - 
      #| - 好
      #| + 世
      #| + 界
      #|
    ),
  )
  inspect(
    print_hunks(line_diff(old~, new~, patience=true)),
    content=(
      #|@@ -1,4 +1,4 @@
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
  inspect(print_hunks(line_diff(old~, new~)), content="")
  inspect(print_hunks(line_diff(old~, new~, patience=true)), content="")
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
    print_hunks(line_diff(old~, new~)),
    content=(
      #|@@ -1,4 +1,4 @@
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
    print_hunks(line_diff(old~, new~, patience=true)),
    content=(
      #|@@ -1,4 +1,4 @@
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
}

///|
test "large text with small hunk" {
  let old =
    #|alert
    #|chop
    #|brave
    #|arise
    #|bring
    #|boy
    #|answer
    #|count
    #|begin
    #|casual
    #|dot
    #|bottom
  let new =
    #|alert
    #|chop
    #|brave
    #|arise
    #|bring
    #|joy
    #|answer
    #|count
    #|begin
    #|casual
    #|dot
    #|bottom
  inspect(
    print_hunks(line_diff(old~, new~)),
    content=(
      #|@@ -3,7 +3,7 @@
      #|   brave
      #|   arise
      #|   bring
      #| - boy
      #| + joy
      #|   answer
      #|   count
      #|   begin
      #|
    ),
  )
  inspect(
    print_hunks(line_diff(old~, new~, patience=true)),
    content=(
      #|@@ -3,7 +3,7 @@
      #|   brave
      #|   arise
      #|   bring
      #| - boy
      #| + joy
      #|   answer
      #|   count
      #|   begin
      #|
    ),
  )
}
