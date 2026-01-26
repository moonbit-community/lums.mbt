///|UUID(8a03c284-fcac-461e-8d89-0032d1bc9f37)
test "basic case with common suffix" {
  let old = ['1', '2', '3', '4', '5']
  let new = ['3', '4', '5', '6', '7']
  json_inspect(@unique_lcs.unique_lcs(old~, new~), content=[
    [2, 0],
    [3, 1],
    [4, 2],
  ])
}

///|UUID(6909915d-bc2e-4315-9a3f-2e3ff1d64d12)
test "reordered elements" {
  let old = ['1', '2', '3']
  let new = ['3', '2', '1']
  json_inspect(@unique_lcs.unique_lcs(old~, new~), content=[[0, 2]])
}

///|UUID(996bd63c-3545-44a4-88cb-9f64cc9d5d58)
test "string array reordering" {
  let old = ["foo", "bar", "baz", "qux"]
  let new = ["baz", "qux", "foo", "bar"]
  json_inspect(@unique_lcs.unique_lcs(old~, new~), content=[[0, 2], [1, 3]])
}

///|UUID(f35a8b17-f010-49e0-973d-fdd914d15961)
test "partial reordering with common elements" {
  let old = ["apple", "banana", "cherry", "date"]
  let new = ["apple", "cherry", "banana", "date"]
  json_inspect(@unique_lcs.unique_lcs(old~, new~), content=[
    [0, 0],
    [2, 1],
    [3, 3],
  ])
}

///|UUID(8e6c54f5-2a26-4a65-b158-c202c7d67d13)
test "empty sequences" {
  let old : Array[String] = []
  let new : Array[String] = []
  json_inspect(@unique_lcs.unique_lcs(old=old[:], new=new[:]), content=[])
}

///|UUID(4c7e8582-2bd6-46ef-bfab-d3cf7794586e)
test "one empty sequence" {
  let old = ["a", "b", "c"]
  let new : Array[String] = []
  json_inspect(@unique_lcs.unique_lcs(old=old[:], new=new[:]), content=[])
}

///|UUID(f2f09994-99ec-4ddc-8c80-4c1d92d287f6)
test "other empty sequence" {
  let old : Array[String] = []
  let new = ["x", "y", "z"]
  json_inspect(@unique_lcs.unique_lcs(old=old[:], new=new[:]), content=[])
}

///|UUID(3b34dd3c-bea3-44b6-94ed-14dfd47ea5e9)
test "identical sequences" {
  let old = ["a", "b", "c", "d"]
  let new = ["a", "b", "c", "d"]
  json_inspect(@unique_lcs.unique_lcs(old~, new~), content=[
    [0, 0],
    [1, 1],
    [2, 2],
    [3, 3],
  ])
}

///|UUID(17f4e31a-ea76-4878-89ba-63dc761e7cbd)
test "completely different sequences" {
  let old = ["a", "b", "c"]
  let new = ["x", "y", "z"]
  json_inspect(@unique_lcs.unique_lcs(old~, new~), content=[])
}

///|UUID(5ad27211-538f-4f4e-995b-3407b49c3a50)
test "single element match" {
  let old = ["a", "b", "c"]
  let new = ["x", "b", "y"]
  json_inspect(@unique_lcs.unique_lcs(old~, new~), content=[[1, 1]])
}

///|UUID(198c2f6d-da9d-4a18-b9de-e4330fd18e35)
test "duplicate elements in old sequence" {
  let old = ["a", "b", "a", "c"]
  let new = ["x", "a", "y", "c"]
  json_inspect(@unique_lcs.unique_lcs(old~, new~), content=[[3, 3]])
}

///|UUID(316989aa-f1bd-4838-b00e-6f6eacf64a8b)
test "duplicate elements in new sequence" {
  let old = ["a", "b", "c"]
  let new = ["x", "b", "b", "y"]
  json_inspect(@unique_lcs.unique_lcs(old~, new~), content=[])
}

///|UUID(ce4ca71e-0894-4592-bbc5-b11bf9820b46)
test "duplicate elements in both sequences" {
  let old = ["a", "b", "b", "c"]
  let new = ["x", "b", "b", "y"]
  json_inspect(@unique_lcs.unique_lcs(old~, new~), content=[])
}

///|UUID(613d09d1-7742-4c2d-bace-d9306eb00c85)
test "long common subsequence" {
  let old = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
  let new = ["0", "2", "4", "6", "8", "10", "11"]
  json_inspect(@unique_lcs.unique_lcs(old~, new~), content=[
    [1, 1],
    [3, 2],
    [5, 3],
    [7, 4],
    [9, 5],
  ])
}

///|UUID(c3cd4ef9-2b72-4b52-9a99-4a4669440dc7)
test "reverse order" {
  let old = ["a", "b", "c", "d"]
  let new = ["d", "c", "b", "a"]
  json_inspect(@unique_lcs.unique_lcs(old~, new~), content=[[0, 3]])
}

///|UUID(1cfc5742-e118-4579-b82c-d91b607bf33c)
test "single character sequences" {
  let old = ["a"]
  let new = ["a"]
  json_inspect(@unique_lcs.unique_lcs(old~, new~), content=[[0, 0]])
}

///|UUID(57dd97f6-db63-4864-aacc-67df6e0340b2)
test "single character no match" {
  let old = ["a"]
  let new = ["b"]
  json_inspect(@unique_lcs.unique_lcs(old~, new~), content=[])
}

///|UUID(8614e95b-8943-44d5-a49c-f2350d8f2e85)
test "prefix and suffix overlap" {
  let old = ["start", "middle1", "middle2", "end"]
  let new = ["start", "new1", "new2", "end"]
  json_inspect(@unique_lcs.unique_lcs(old~, new~), content=[[0, 0], [3, 3]])
}

///|UUID(fe5754aa-ce06-4871-ae80-ec9f62b0f69f)
test "interleaved unique elements" {
  let old = ["a1", "b1", "a2", "b2", "a3"]
  let new = ["b1", "a1", "b2", "a2", "a3"]
  json_inspect(@unique_lcs.unique_lcs(old~, new~), content=[
    [0, 1],
    [3, 2],
    [4, 4],
  ])
}

///|UUID(2a1e4ccd-6128-46b6-8e75-752201239f81)
test "numeric sequences" {
  let old = [1, 3, 5, 7, 9]
  let new = [2, 3, 4, 7, 8, 9]
  json_inspect(@unique_lcs.unique_lcs(old~, new~), content=[
    [1, 1],
    [3, 3],
    [4, 5],
  ])
}

///|UUID(f99de984-7644-4ab6-9c20-908e6ff8a041)
test "mixed types - booleans" {
  let old = [true, false, true, false]
  let new = [false, true, false, true]
  // TODO: check this
  json_inspect(@unique_lcs.unique_lcs(old~, new~), content=[])
}

///|UUID(d51c746f-d2a3-47bb-9f05-11975cd0055e)
test "large gap in middle" {
  let old = ["start", "gap1", "gap2", "gap3", "gap4", "end"]
  let new = ["start", "different", "end"]
  json_inspect(@unique_lcs.unique_lcs(old~, new~), content=[[0, 0], [5, 2]])
}

///|UUID(84ee995f-56ef-4b2b-965b-e78a10b2cb61)
test "insertion at beginning" {
  let old = ["b", "c", "d"]
  let new = ["a", "b", "c", "d"]
  json_inspect(@unique_lcs.unique_lcs(old~, new~), content=[
    [0, 1],
    [1, 2],
    [2, 3],
  ])
}

///|UUID(70467f17-439c-4763-a2d8-49108e770002)
test "insertion at end" {
  let old = ["a", "b", "c"]
  let new = ["a", "b", "c", "d"]
  json_inspect(@unique_lcs.unique_lcs(old~, new~), content=[
    [0, 0],
    [1, 1],
    [2, 2],
  ])
}

///|UUID(d6871b80-cc83-49ee-927c-bb8a9876cc2c)
test "deletion from beginning" {
  let old = ["a", "b", "c", "d"]
  let new = ["b", "c", "d"]
  json_inspect(@unique_lcs.unique_lcs(old~, new~), content=[
    [1, 0],
    [2, 1],
    [3, 2],
  ])
}

///|UUID(9fb2f84f-d7de-49a6-aba9-5d1bc18caf98)
test "deletion from end" {
  let old = ["a", "b", "c", "d"]
  let new = ["a", "b", "c"]
  json_inspect(@unique_lcs.unique_lcs(old~, new~), content=[
    [0, 0],
    [1, 1],
    [2, 2],
  ])
}

///|UUID(71abc6eb-756d-4af5-b059-834ae6ff61ee)
test "complex pattern with multiple unique matches" {
  let old = ["alpha", "beta", "gamma", "delta", "epsilon", "zeta"]
  let new = ["gamma", "alpha", "theta", "epsilon", "beta", "eta"]
  json_inspect(@unique_lcs.unique_lcs(old~, new~), content=[[0, 1], [4, 3]])
}
