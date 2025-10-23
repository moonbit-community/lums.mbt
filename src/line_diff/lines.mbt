///|
fn lines(str : StringView) -> Array[Line] {
  let lines = Array::new(capacity=50)
  for text in str.split("\n") {
    lines.push(Line::{ text, })
  } else {
    return lines
  }
}

///|
fn width_for_lines(lines : ArrayView[Line], base_line_number? : Int = 1) -> Int {
  // assume last line have maximum line number
  let maximum_line_number = lines.length() - 1 + base_line_number
  match maximum_line_number {
    0..=9 => 2
    10..=99 => 3
    100..=999 => 4
    1000..=9999 => 5
    10000..=99999 => 6
    100000..=999999 => 7
    1000000..=9999999 => 8
    10000000..=99999999 => 9
    _ => abort("input too big!")
  }
}
