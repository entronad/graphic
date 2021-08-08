import 'dart:math';

List<T> sublist<T>(
  List<T> list,
  int start,
  int end,
) =>
  list.sublist(start, min(end, list.length));
