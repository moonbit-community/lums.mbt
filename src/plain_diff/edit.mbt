///|
pub enum Edit {
  Delete(old_index~ : Int, new_index~ : Int, old_len~ : Int)
  Insert(old_index~ : Int, new_index~ : Int, new_len~ : Int)
  Equal(mut old_index~ : Int, mut new_index~ : Int, mut len~ : Int)
} derive(Show, ToJson)

///|
fn Edit::old_range(self : Edit) -> (Int, Int) {
  match self {
    Insert(old_index~, ..) => (old_index, old_index)
    Delete(old_index~, old_len~, ..) => (old_index, old_index + old_len)
    Equal(old_index~, len~, ..) => (old_index, old_index + len)
  }
}

///|
fn Edit::new_range(self : Edit) -> (Int, Int) {
  match self {
    Insert(new_index~, new_len~, ..) => (new_index, new_index + new_len)
    Delete(old_index~, ..) => (old_index, old_index)
    Equal(new_index~, len~, ..) => (new_index, new_index + len)
  }
}

///|
/// Isolate change clusters by eliminating ranges with no changes.
///
/// This will leave holes behind in long periods of equal ranges so that
/// you can build things like unified diffs.
pub fn group_edits(
  edits : Array[Edit],
  radius? : Int = 3,
) -> Array[Array[Edit]] {
  if edits.is_empty() {
    return []
  }
  let mut pending_group = Array::new()
  let result = Array::new()

  // cut first equal sequence to size limit
  if edits[0] is (Equal(_) as first_edit) {
    let offset = first_edit.len.saturating_sub(radius)
    first_edit.old_index += offset
    first_edit.new_index += offset
    first_edit.len -= offset
  }

  // cut last equal sequence to size limit
  if edits.last() is Some(Equal(_) as last_edit) {
    last_edit.len -= last_edit.len.saturating_sub(radius)
  }
  for edit in edits {
    if edit is (Equal(_) as edit) {
      // End the current group and start a new one whenever
      // there is a large range with no changes.
      if edit.len > radius * 2 {
        pending_group.push(
          Equal(old_index=edit.old_index, new_index=edit.new_index, len=radius),
        )
        result.push(pending_group)
        let offset = edit.len.saturating_sub(radius)
        pending_group = [
          Equal(
            old_index=edit.old_index + offset,
            new_index=edit.new_index + offset,
            len=edit.len - offset,
          ),
        ]
        continue
      }
    }
    pending_group.push(edit)
  }
  if !(pending_group is [] || pending_group is [Equal(_)]) {
    result.push(pending_group)
  }
  return result
}

///|
fn Int::saturating_sub(self : Int, subtrahend : Int) -> Int {
  if self < subtrahend {
    0
  } else {
    self - subtrahend
  }
}
