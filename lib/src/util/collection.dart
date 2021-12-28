import 'dart:math';

E? singleIntersection<E>(Iterable<E>? a, Iterable<E>? b) {
  if (a == null || b == null || a.isEmpty || b.isEmpty) {
    return null;
  }

  final rst = a.where((element) => b.contains(element));
  if (rst.isEmpty) {
    return null;
  } else {
    return rst.single;
  }
}

extension ListExt<E> on List<E> {
  /// Gets a sublist safely avoiding [end] overflow.
  List<E> safeSublist(int start, [int? end]) =>
      sublist(start, min(end ?? length, length));

  /// Gets a deduplicated list when list items are collections.
  List<E> collectionItemDeduplicate() {
    final rst = <E>[];
    for (var item in this) {
      bool duplicate = false;
      for (var rstItem in rst) {
        if (deepCollectionEquals(item, rstItem)) {
          duplicate = true;
        }
      }
      if (!duplicate) {
        rst.add(item);
      }
    }
    return rst;
  }
}

bool deepCollectionEquals<T>(T? a, T? b) {
  if (a == b) {
    return true;
  }
  if (a == null || b == null) {
    return false;
  }

  // Since the equality is for specification literals, sets are also treated ordered.
  // Thus equal Sets should have same order. This avoids collection item duplication
  // in sets: {{1, 1}, {1, 1}} and {{1, 1}, {1, 2}}.
  if (a is Iterable) {
    b as Iterable;
    if (a.length != b.length) {
      return false;
    }
    final aList = a.toList();
    final bList = b.toList();
    for (var i = 0; i < a.length; i++) {
      if (!deepCollectionEquals(aList[i], bList[i])) {
        return false;
      }
    }
    return true;
  }
  if (a is Map) {
    b as Map;
    if (a.length != b.length) {
      return false;
    }
    for (var key in a.keys) {
      if (!deepCollectionEquals(a[key], b[key])) {
        return false;
      }
    }
    return true;
  }
  return false;
}
