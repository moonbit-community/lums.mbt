///|
pub fn[T : Eq + Hash] longest_unique_matching_subsequence(
  old~ : ArrayView[T],
  new~ : ArrayView[T],
) -> Array[(Int, Int)] {
  let matchs = find_unique(old~, new~)
  let piles : Piles[BackPointer[(Int, Int)]] = Array::new(
    capacity=matchs.length(),
  )
  for place = 0; place < matchs.length(); place = place + 1 {
    let (_, new_idx) = matchs[place]
    if piles.is_empty() {
      piles.put_back(BackPointer::{ value: (new_idx, place), prev: None })
    } else {
      piles.put_by_binary_search(new_idx~, place~)
    }
  }
  guard piles.last() is Some(head) else { return [] }
  let seq = []
  for pair in head.top.to_array().iter() {
    let (_, place) = pair
    seq.push(matchs[place])
  }
  return seq
}
