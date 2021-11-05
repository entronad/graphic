import 'package:collection/collection.dart';

/// A equality that only checks the map keys.
///
/// This is used for map specifications whose values are functions.
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
