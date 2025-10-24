///|
priv struct MutArrayView[T] {
  content : Array[T]
  start : Int
  end : Int
}

///|
fn[T] MutArrayView::length(self : MutArrayView[T]) -> Int {
  self.end - self.start
}

///|
fn[T] MutArrayView::op_get(self : MutArrayView[T], index : Int) -> T {
  // guard index < (self.end - self.start)
  self.content[self.start + index]
}

///|
fn[T] MutArrayView::op_set(
  self : MutArrayView[T],
  index : Int,
  elem : T,
) -> Unit {
  self.content[self.start + index] = elem
}

///|
fn[T] Array::mut_view(
  self : Array[T],
  start~ : Int,
  end~ : Int,
) -> MutArrayView[T] {
  MutArrayView::{ content: self, start, end }
}
