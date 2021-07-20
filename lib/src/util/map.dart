import 'package:collection/collection.dart';

extension MapExt<K, V> on Map<K, V> {
  /// If no such value will throw an exception.
  K keyOf(V value) => keys.firstWhere(
    (key) => this[key] == value,
  );
}

class MapKeyEquality<E extends Map> implements Equality<E> {
  const MapKeyEquality();

  @override
  bool equals(Map? e1, Map? e2) =>
    DeepCollectionEquality().equals(e1?.keys, e2?.keys);

  @override
  int hash(Object? e) => e.hashCode;

  @override
  bool isValidKey(Object? o) => true;
}
