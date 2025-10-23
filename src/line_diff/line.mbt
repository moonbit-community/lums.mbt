///|
priv struct Line {
  line_number : Int // Line number
  text : StringView // Does not include newline
} derive(Show)

///|
impl Hash for Line with hash_combine(self, hasher) {
  hasher.combine(self.text)
}

///|
impl Eq for Line with equal(self, other) {
  self.text == other.text
}
