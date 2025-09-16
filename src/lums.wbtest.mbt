///|
test {
  let old = [1, 2, 3, 4, 5]
  let new = [3, 4, 5, 6, 7]
  @json.inspect(find_unique(old~, new~), content=[[2, 0], [3, 1], [4, 2]])
}

///|
test {
  let old : Array[Int] = []
  let new = []
  @json.inspect(find_unique(old~, new~), content=[])
}

///|
test {
  let old = [1, 2, 3]
  let new : Array[Int] = [3, 2, 1]
  @json.inspect(find_unique(old~, new~), content=[[0, 2], [1, 1], [2, 0]])
}
