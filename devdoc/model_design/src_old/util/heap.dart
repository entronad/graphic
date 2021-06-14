class Heap<T> {
  Heap(this.cmp);

  final Comparator<T> cmp;
  List<T> _nodes = [];

  void clear() {
    _nodes = [];
  }

  int get size => _nodes.length;

  T get peek => _nodes.first;

  T push(T x) {
    _nodes.add(x);
    return _shiftDown(_nodes, 0, _nodes.length - 1, cmp);
  }

  T pop() {
    final last = _nodes.removeLast();
    T item;
    if (_nodes.isNotEmpty) {
      item = _nodes.first;
      _nodes.first = last;
      _shiftUp(_nodes, 0, cmp);
    } else {
      item = last;
    }
    return item;
  }
}

T _shiftDown<T>(
  List<T> list,
  int start,
  int index,
  Comparator<T> cmp,
) {
  T parent;
  int parentIndex;

  final item = list[index];
  while (index > start) {
    parentIndex = (index - 1) >> 1;
    parent = list[parentIndex];
    if (cmp(item, parent) < 0) {
      list[index] = parent;
      index = parentIndex;
      continue;
    }
    break;
  }
  list[index] = item;
  return list[index];
}

T _shiftUp<T>(
  List<T> list,
  int index,
  Comparator<T> cmp,
) {
  final start = index;
  final end = list.length;
  final item = list[index];
  var currentIndex = (index << 1) + 1;
  int rightIndex;

  while (currentIndex < end) {
    rightIndex = currentIndex + 1;
    if (
      rightIndex < end
        && cmp(list[currentIndex], list[rightIndex]) >= 0
    ) {
      currentIndex = rightIndex;
    }
    list[index] = list[currentIndex];
    index = currentIndex;
    currentIndex = (index << 1) + 1;
  }
  list[index] = item;
  return _shiftDown(list, start, index, cmp);
}
