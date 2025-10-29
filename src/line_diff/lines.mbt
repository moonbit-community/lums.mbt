///|
fn lines(str : StringView) -> Array[Line] {
  let lines = Array::new(capacity=50)
  for text in str.split("\n") {
    lines.push(Line::{ text, })
  } else {
    return lines
  }
}
