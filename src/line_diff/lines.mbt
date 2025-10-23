///|
fn lines(str : StringView) -> Array[Line] {
  let lines = Array::new(capacity=50)
  let mut line_number = 0
  for text in str.split("\n") {
    line_number = line_number + 1
    lines.push(Line::{ line_number, text })
  } else {
    return lines
  }
}

///|
fn width_for_lines(old~ : ArrayView[Line], new~ : ArrayView[Line]) -> Int {
  // assume last line have maximum line number
  let maximum_line_number = @cmp.maximum(
    old[old.length() - 1].line_number,
    new[new.length() - 1].line_number,
  )
  match maximum_line_number {
    0..=9 => 3
    10..=19 => 4
    100..=999 => 5
    1000..=9999 => 6
    10000..=99999 => 7
    100000..=999999 => 8
    1000000..=9999999 => 9
    10000000..=99999999 => 10
    _ => abort("input too big!")
  }
}
