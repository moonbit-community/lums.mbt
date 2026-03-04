///|
pub fn[T : Eq + Hash] patience_diff(
  old~ : @builtin.MutArrayView[T],
  new~ : @builtin.MutArrayView[T],
  cutoff? : Int,
) -> Array[@plain_diff.Edit] {
  let result = Array::new()
  let barriers = @unique_lcs.unique_lcs(old=old[:], new=new[:])
  let mut prev_old = 0
  let mut prev_new = 0
  for barrier in barriers {
    let edits = match cutoff {
      Some(cutoff) =>
        @plain_diff.plain_diff(
          old=old.mut_view(start=prev_old, end=barrier.0),
          new=new.mut_view(start=prev_new, end=barrier.1),
          cutoff~,
        )
      None =>
        @plain_diff.plain_diff(
          old=old.mut_view(start=prev_old, end=barrier.0),
          new=new.mut_view(start=prev_new, end=barrier.1),
        )
    }
    for edit in edits {
      // add offset
      match edit {
        Insert(_) as edit => {
          edit.old_index += prev_old
          edit.new_index += prev_new
        }
        Delete(_) as edit => {
          edit.old_index += prev_old
          edit.new_index += prev_new
        }
        Equal(_) as edit => {
          edit.old_index += prev_old
          edit.new_index += prev_new
        }
      }
      result.push_and_merge_consecutive_equal(edit)
    }
    prev_old = barrier.0
    prev_new = barrier.1
  } nobreak {
    let old = old.mut_view(start=prev_old, end=old.length())
    let new = new.mut_view(start=prev_new, end=new.length())
    let edits = match cutoff {
      Some(cutoff) => @plain_diff.plain_diff(old~, new~, cutoff~)
      None => @plain_diff.plain_diff(old~, new~)
    }
    for edit in edits {
      // add offset
      match edit {
        Insert(_) as edit => {
          edit.old_index += prev_old
          edit.new_index += prev_new
        }
        Delete(_) as edit => {
          edit.old_index += prev_old
          edit.new_index += prev_new
        }
        Equal(_) as edit => {
          edit.old_index += prev_old
          edit.new_index += prev_new
        }
      }
      result.push_and_merge_consecutive_equal(edit)
    }
  }
  return result
}

///|
fn Array::push_and_merge_consecutive_equal(
  self : Array[@plain_diff.Edit],
  edit : @plain_diff.Edit,
) -> Unit {
  if self.last() is Some(Equal(..) as prev_edit) && edit is (Equal(..) as edit) {
    // not check 
    prev_edit.len += edit.len
  } else {
    self.push(edit)
  }
}
