import 'dart:math';

List<T> sublist<T>(
  List<T> list,
  int start,
  int end,
) =>
  list.sublist(start, min(end, list.length));

List<List<D>> group<V, D>(
  List<D> data,
  V Function(D) accessor,
) {
  if (accessor == null || data == null || data.isEmpty) {
    return [];
  }

  final tmp = <V, List<D>>{};

  for (var datum in data) {
    final value = accessor(datum);
    if (tmp[value] == null) {
      tmp[value] = <D>[];
    }
    tmp[value].add(datum);
  }

  return tmp.values.toList();
}
