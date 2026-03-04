///|
pub fn line_diff(
  old~ : StringView,
  new~ : StringView,
  patience? : Bool = false,
) -> Array[(@edit.HunkHeader, Array[(@edit.EditTag, StringView)])] {
  let old = lines(old).mut_view()
  let new = lines(new).mut_view()
  let result = Array::new(capacity=old.length() + new.length())
  let edits = if patience {
    @patience.patience_diff(old~, new~)
  } else {
    @plain_diff.plain_diff(old~, new~)
  }
  let hunks = @edit.group_edits(edits)
  for hunk in hunks {
    let header = @edit.HunkHeader::new(hunk)
    let edits = Array::new(capacity=hunk.length())
    for edit in hunk {
      let tag = edit.tag()
      match edit {
        Delete(old_index~, old_len~, ..) =>
          for i in 0..<old_len {
            edits.push((tag, old[old_index + i].text))
          }
        Insert(new_index~, new_len~, ..) =>
          for i in 0..<new_len {
            edits.push((tag, new[new_index + i].text))
          }
        Equal(old_index~, len~, ..) =>
          for i in 0..<len {
            edits.push((tag, old[old_index + i].text))
          }
      }
    }
    result.push((header, edits))
  }
  result
}
