///|
test {
  let old = [1, 2, 3, 4, 5]
  let new = [3, 4, 5, 6, 7]
  @json.inspect(@lums.longest_unique_matching_subsequence(old~, new~), content=[
    [2, 0],
    [3, 1],
    [4, 2],
  ])
}

///|
test {
  let old = [1, 2, 3]
  let new : Array[Int] = [3, 2, 1]
  @json.inspect(@lums.longest_unique_matching_subsequence(old~, new~), content=[
    [0, 2],
  ])
}

///|
test {
  let old = ["foo", "bar", "baz", "qux"]
  let new = ["baz", "qux", "foo", "bar"]
  @json.inspect(@lums.longest_unique_matching_subsequence(old~, new~), content=[
    [0, 2],
    [1, 3],
  ])
}

///|
test {
  let old = ["apple", "banana", "cherry", "date"]
  let new = ["apple", "cherry", "banana", "date"]
  @json.inspect(@lums.longest_unique_matching_subsequence(old~, new~), content=[
    [0, 0],
    [2, 1],
    [3, 3],
  ])
}
