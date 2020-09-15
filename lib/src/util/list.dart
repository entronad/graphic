import 'dart:math';

List<T> sublist<T>(
  List<T> list,
  int start,
  int end,
) =>
  list.sublist(start, min(end, list.length));

T get<T>(List<T> list, int i) =>
  i < list.length ? list[i] : null;

List<List<D>> group<V, D>(
  List<D> data,
  V Function(D) accessor,
  List<V> values,
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

  if (values != null) {
    return values.map((groupValue) => tmp[groupValue]).toList();
  }

  return tmp.values.toList();
}

List<T> makeup<T>(
  List<T> list,
  int length,
  [T placeholder,]
) {
  if (list == null) {
    return null;
  }

  if (list.length >= length) {
    return list.sublist(0, length);
  }

  placeholder = placeholder ?? list.last;

  return [...list, ...List.filled(length - list.length, placeholder)];
}
