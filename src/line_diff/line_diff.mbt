///|
pub fn line_diff(old~ : StringView, new~ : StringView) -> String {
  let buf = StringBuilder::new(size_hint=(old.length() + new.length()) * 3 / 2)
  let old = lines(old)
  let new = lines(new)
  let edits = @plain_diff.plain_diff(old~, new~)
  let hunks = @plain_diff.group_edits(edits)
  for hunk in hunks {
    let header = @plain_diff.HunkHeader::new(hunk)
    buf.write_string(header.to_string())
    buf.write_char('\n')
    for edit in hunk {
      match edit {
        Delete(old_index~, old_len~, ..) =>
          for i in 0..<old_len {
            buf.write_string(" - ")
            buf.write_stringview(old[old_index + i].text)
            buf.write_char('\n')
          }
        Insert(new_index~, new_len~, ..) =>
          for i in 0..<new_len {
            buf.write_string(" + ")
            buf.write_stringview(new[new_index + i].text)
            buf.write_char('\n')
          }
        Equal(old_index~, len~, ..) =>
          for i in 0..<len {
            buf.write_string("   ")
            buf.write_stringview(old[old_index + i].text)
            buf.write_char('\n')
          }
      }
    }
  }
  buf.to_string()
}
