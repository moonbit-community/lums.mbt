///|
priv struct Piles[T](Array[Pile[T]])

///|
fn[T] Piles::is_empty(self : Piles[T]) -> Bool {
  self.0.is_empty()
}

///|
fn[T] Piles::put_back(self : Piles[T], singleton : T) -> Unit {
  self.0.push(Stack::{ top: singleton, stack: @list.empty() })
}

///|
fn[T] Piles::last(self : Piles[T]) -> Pile[T]? {
  self.0.last()
}

///|
fn[T] Piles::op_get(self : Piles[T], i : Int) -> Pile[T] {
  self.0[i]
}

///|
fn Piles::put_by_binary_search(
  self : Piles[BackPointer[(Int, Int)]],
  new_idx~ : Int,
  place~ : Int,
) -> Unit {
  let mut lo = -1
  let mut hi = self.0.length()
  while lo + 1 < hi {
    let mid = (lo + hi) / 2
    if self[mid].top.value.0 < new_idx {
      lo = mid
    } else {
      hi = mid
    }
  }
  if lo >= 0 {
    let prev = Some(self[lo].top)
    if lo + 1 < self.0.length() {
      self[lo + 1].push(BackPointer::{ value: (new_idx, place), prev })
    } else {
      self.put_back(BackPointer::{ value: (new_idx, place), prev })
    }
  }
}
