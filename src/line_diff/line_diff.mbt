///|
// TODO: output_line_number~ : Bool, 
pub fn line_diff(old~ : StringView, new~ : StringView) -> String {
  let buf = StringBuilder::new(size_hint=(old.length() + new.length()) * 3 / 2)
  let old = lines(old)
  let new = lines(new)
  let mut prev_old_idx = 0
  let mut prev_new_idx = 0
  for old_idx, new_idx in @plain_diff.iter_matches(old~, new~) {
    for i in prev_old_idx..<old_idx {
      // emit delete
      buf.write_string("- ")
      buf.write_stringview(old[i].text)
      buf.write_char('\n')
    } else {
      prev_old_idx = old_idx + 1
    }
    for i in prev_new_idx..<new_idx {
      // emit insert
      buf.write_string("+ ")
      buf.write_stringview(new[i].text)
      buf.write_char('\n')
    } else {
      prev_new_idx = new_idx + 1
    }
    // emit equal
    buf.write_string("  ")
    buf.write_stringview(old[old_idx].text)
    buf.write_char('\n')
  } else {
    // emit remaining deletions
    for i in prev_old_idx..<old.length() {
      buf.write_string("- ")
      buf.write_stringview(old[i].text)
      buf.write_char('\n')
    }
    // emit remaining insertions
    for i in prev_new_idx..<new.length() {
      buf.write_string("+ ")
      buf.write_stringview(new[i].text)
      buf.write_char('\n')
    }
    buf.to_string()
  }
}
