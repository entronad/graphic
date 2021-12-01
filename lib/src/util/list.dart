import 'dart:math';

import 'package:collection/collection.dart';

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
        if (DeepCollectionEquality().equals(item, rstItem)) {
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
