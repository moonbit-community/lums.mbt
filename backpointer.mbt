///|
/// A node in the predecessor chain recovered from the patience-sorting phase.
///
/// `value` stores the current pile entry, and `prev` points to the entry chosen
/// from the previous pile so the final increasing chain can be reconstructed
/// once the last pile is known.
priv struct BackPointer[T] {
  value : T
  prev : BackPointer[T]?
}

///|
/// Materialize the predecessor chain ending at `self`, preserving left-to-right
/// subsequence order.
fn[T] BackPointer::to_array(self : BackPointer[T]) -> Array[T] {
  let result = []
  let mut self = self
  while self.prev is Some(prev) {
    result.push(self.value)
    self = prev
  }
  result.push(self.value)
  return result.rev()
}
