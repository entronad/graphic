import 'dart:math';

/// Gets a sublist safely avoiding [end] overflow.
List<T> sublist<T>(
  List<T> list,
  int start,
  int end,
) =>
    list.sublist(start, min(end, list.length));
