///|
pub fn line_diff(
  old~ : StringView,
  new~ : StringView,
  output_line_number? : Bool = false,
) -> String {
  let buf = StringBuilder::new(size_hint=(old.length() + new.length()) * 3 / 2)
  let old = lines(old)
  let new = lines(new)
  let old_maximum_line_number_width = width_for_lines(old)
  let new_maximum_line_number_width = width_for_lines(new)
  let mut prev_old_idx = 0
  let mut prev_new_idx = 0
  for old_idx, new_idx in @plain_diff.iter_matches(old~, new~) {
    for i in prev_old_idx..<old_idx {
      // emit delete
      if output_line_number {
        buf.write_string(
          (i + 1).to_string().pad_end(old_maximum_line_number_width, ' '),
        )
        buf.write_char(' ')
        for i in 0..<new_maximum_line_number_width {
          buf.write_char(' ')
        }
      }
      buf.write_string(" - ")
      buf.write_stringview(old[i].text)
      buf.write_char('\n')
    } else {
      prev_old_idx = old_idx + 1
    }
    for i in prev_new_idx..<new_idx {
      // emit insert
      if output_line_number {
        for i in 0..<old_maximum_line_number_width {
          buf.write_char(' ')
        }
        buf.write_char(' ')
        buf.write_string(
          (i + 1).to_string().pad_end(new_maximum_line_number_width, ' '),
        )
      }
      buf.write_string(" + ")
      buf.write_stringview(new[i].text)
      buf.write_char('\n')
    } else {
      prev_new_idx = new_idx + 1
    }
    // emit equal
    if output_line_number {
      buf.write_string(
        (old_idx + 1).to_string().pad_end(old_maximum_line_number_width, ' '),
      )
      buf.write_char(' ')
      buf.write_string(
        (new_idx + 1).to_string().pad_end(new_maximum_line_number_width, ' '),
      )
    }
    buf.write_string("   ")
    buf.write_stringview(old[old_idx].text)
    buf.write_char('\n')
  } else {
    // emit remaining deletions
    for i in prev_old_idx..<old.length() {
      if output_line_number {
        buf.write_string(
          (i + 1).to_string().pad_end(old_maximum_line_number_width, ' '),
        )
        buf.write_char(' ')
        for i in 0..<new_maximum_line_number_width {
          buf.write_char(' ')
        }
      }
      buf.write_string(" - ")
      buf.write_stringview(old[i].text)
      buf.write_char('\n')
    }
    // emit remaining insertions
    for i in prev_new_idx..<new.length() {
      if output_line_number {
        for i in 0..<old_maximum_line_number_width {
          buf.write_char(' ')
        }
        buf.write_char(' ')
        buf.write_string(
          (i + 1).to_string().pad_end(new_maximum_line_number_width, ' '),
        )
      }
      buf.write_string(" + ")
      buf.write_stringview(new[i].text)
      buf.write_char('\n')
    }
    buf.to_string()
  }
}
