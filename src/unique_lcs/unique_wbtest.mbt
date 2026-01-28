///|UUID(c9369ad9-f833-4557-aa9b-131d360e660a)
test {
  let old = [1, 2, 3, 4, 5]
  let new = [3, 4, 5, 6, 7]
  json_inspect(find_unique(old~, new~), content=[[2, 0], [3, 1], [4, 2]])
}

///|UUID(89ca0da5-fc45-43bb-90b9-46501f5b96de)
test {
  let old : Array[Int] = []
  let new = []
  json_inspect(find_unique(old~, new~), content=[])
}

///|UUID(7b617684-478b-41db-b887-98ae7ba5a4cc)
test {
  let old = [1, 2, 3]
  let new : Array[Int] = [3, 2, 1]
  json_inspect(find_unique(old~, new~), content=[[0, 2], [1, 1], [2, 0]])
}
