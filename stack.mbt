///|
/// `Pile[T]` models one pile in patience sorting.
///
/// `top` is the visible card consulted by binary search. `stack` retains older
/// cards underneath it so the pile still behaves like a stack.
#alias(Pile)
priv struct Stack[T] {
  mut top : T
  mut stack : @list.List[T]
}

///|
/// Push a new card onto the pile, demoting the old top underneath it.
fn[T] Stack::push(self : Stack[T], t : T) -> Unit {
  self.stack = self.stack.add(self.top)
  self.top = t
}
