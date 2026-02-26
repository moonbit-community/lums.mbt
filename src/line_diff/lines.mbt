///|UUID(3a73bd2b-8949-4e0f-b096-c911fa95df1c)
fn lines(str : StringView) -> Array[Line] {
  let lines = Array::new(capacity=50)
  for text in str.split("\n") {
    lines.push(Line::{ text, })
  } nobreak {
    return lines
  }
}
