# Piediff

[![check](https://github.com/moonbit-community/piediff/actions/workflows/stable_check.yml/badge.svg)](https://github.com/moonbit-community/piediff/actions/workflows/stable_check.yml)

Piediff is a MoonBit implementation of Bram Cohen's patience diff algorithm (also provides a basic Myers diff).

## Compute A Diff

`Diff(old~, new~)` computes the full sequence of `Delete`, `Insert`, and
`Equal` operations, accessible via the `edits` field.

```mbt check
///|
test "Diff computes deletes inserts and equals" {
  let old = ["apple", "pear", "banana"][:]
  let new = ["apple", "banana", "coconut"][:]

  let d = @piediff.Diff(old~, new~)

  assert_eq(d.edits.length(), 4)
  assert_true(
    d.edits[:]
    is [
      Equal(old_index=0, new_index=0, len=1),
      Delete(old_index=1, new_index=1, len=1),
      Equal(old_index=2, new_index=1, len=1),
      Insert(old_index=3, new_index=2, len=1),
    ],
  )
}
```

## Prefer Unique Anchors With Patience Diff

Pass `algorithm=@piediff.Patience` to `Diff(old~, new~, algorithm=@piediff.Patience)` to enable
patience diff. This first finds elements that appear exactly once in both
inputs and uses them as anchors, then runs Myers diff on the unmatched ranges
between those anchors. This can produce more stable result when repeated
elements move around.

```mbt check
///|
test "patience diff keeps unique anchors in place" {
  let old = ["unique", "dup", "dup"][:]
  let new = ["dup", "unique", "dup"][:]

  let myers = @piediff.Diff(old~, new~)
  let patience = @piediff.Diff(old~, new~, algorithm=@piediff.Patience)

  assert_true(
    myers.edits[:]
    is [
      Delete(old_index=0, new_index=0, len=1),
      Equal(old_index=1, new_index=0, len=1),
      Insert(old_index=2, new_index=1, len=1),
      Equal(old_index=2, new_index=2, len=1),
    ],
  )
  assert_true(
    patience.edits[:]
    is [
      Insert(old_index=0, new_index=0, len=1),
      Equal(old_index=0, new_index=1, len=2),
      Delete(old_index=2, new_index=3, len=1),
    ],
  )
}
```

## Group Into Hunks And Render

`group` splits the edit script into `Hunk[T]` values, keeping `radius` lines
of surrounding context (default 3). `radius` must be non-negative, and
`radius=0` emits hunks without surrounding context. Each `Hunk[T]` implements
`Show`, so you can print it directly as unified-diff output.

```mbt check
///|
test "group splits distant changes into separate hunks" {
  let old = [
      " aaaaaaaaaa", " bbbbbbbbbb", " cccccccccc", " dddddddddd", " eeeeeeeeee",
      " ffffffffff", " gggggggggg", " hhhhhhhhhh",
    ][:]
  let new = [
      " aaaaaaaaaa", " xxxxxxxxxx", " cccccccccc", " dddddddddd", " eeeeeeeeee",
      " ffffffffff", " yyyyyyyyyy", " hhhhhhhhhh",
    ][:]

  let hunks = @piediff.Diff(old~, new~).group(radius=1)

  assert_eq(hunks.length(), 2)
  assert_eq(
    hunks[0].to_string(),
    (
      #|@@ -1,3 +1,3 @@
      #|  aaaaaaaaaa
      #|- bbbbbbbbbb
      #|+ xxxxxxxxxx
      #|  cccccccccc
      #|
    ),
  )
  assert_eq(
    hunks[1].to_string(),
    (
      #|@@ -6,3 +6,3 @@
      #|  ffffffffff
      #|- gggggggggg
      #|+ yyyyyyyyyy
      #|  hhhhhhhhhh
      #|
    ),
  )
}
```
